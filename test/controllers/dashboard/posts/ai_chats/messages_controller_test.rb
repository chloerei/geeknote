require "test_helper"

class Dashboard::Posts::AIChats::MessagesControllerTest < ActionDispatch::IntegrationTest
  test "should create message and enqueue response job" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    sign_in user

    assert_difference "ai_chat.ai_messages.count", 1 do
      assert_enqueued_with(job: AIChatResponseJob, queue: "llm", args: [ ai_chat ]) do
        post dashboard_post_ai_chat_messages_url(user.account.name, post, ai_chat), as: :turbo_stream, params: {
          ai_message: { content: "Continue writing" }
        }
      end
    end

    assert_equal "user", ai_chat.ai_messages.last.role
    assert_equal "Continue writing", ai_chat.ai_messages.last.content
    assert_predicate ai_chat.reload, :processing?
    assert_response :success
  end

  test "should respond with turbo stream after creating message" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    sign_in user

    post dashboard_post_ai_chat_messages_url(user.account.name, post, ai_chat), as: :turbo_stream, params: {
      ai_message: { content: "Continue writing" }
    }

    assert_response :success
  end

  test "should clear pending cancellation when creating message" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    ai_chat.update_columns(cancelled: true)
    sign_in user

    post dashboard_post_ai_chat_messages_url(user.account.name, post, ai_chat), as: :turbo_stream, params: {
      ai_message: { content: "Continue writing" }
    }

    assert_not ai_chat.reload.cancelled?
    assert_predicate ai_chat, :processing?
  end

  test "should update chat snapshot when creating message" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    sign_in user

    post dashboard_post_ai_chat_messages_url(user.account.name, post, ai_chat), as: :turbo_stream, params: {
      ai_message: { content: "Continue writing" },
      snapshot: { title: "New title", content: "New body" }
    }

    assert_equal({ "title" => "New title", "content" => "New body" }, ai_chat.reload.snapshot)
  end

  test "should not enqueue job without content" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    sign_in user

    assert_no_enqueued_jobs only: AIChatResponseJob do
      post dashboard_post_ai_chat_messages_url(user.account.name, post, ai_chat), params: {
        ai_message: { content: "" }
      }
    end

    assert_response :no_content
  end

  test "should not send message to chat of other post" do
    user = create(:user)
    post = create(:post)
    ai_chat = create(:ai_chat, post: post, user: post.user)
    sign_in user

    post dashboard_post_ai_chat_messages_url(user.account.name, post, ai_chat), params: {
      ai_message: { content: "Continue writing" }
    }
    assert_response :not_found
  end

  test "should update user message, truncate tail, and restart round when idle" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    edited = create(:ai_message, ai_chat: ai_chat, role: "user", content: "original prompt")
    later_user = create(:ai_message, ai_chat: ai_chat, role: "user", content: "follow-up")
    answer = create(:ai_message, ai_chat: ai_chat, role: "assistant", content: "old answer")
    sign_in user

    assert_difference "ai_chat.ai_messages.count", -2 do
      assert_enqueued_with(job: AIChatResponseJob, args: [ ai_chat ]) do
        patch dashboard_post_ai_chat_message_url(user.account.name, post, ai_chat, edited), as: :turbo_stream, params: {
          ai_message: { content: "edited prompt" },
          snapshot: { title: "New title", content: "New body" }
        }
      end
    end

    assert_response :success
    assert_equal "edited prompt", edited.reload.content
    assert_not AI::Message.exists?(later_user.id)
    assert_not AI::Message.exists?(answer.id)
    assert_predicate ai_chat.reload, :processing?
    assert_nil ai_chat.restart_from_message_id
    assert_equal({ "title" => "New title", "content" => "New body" }, ai_chat.snapshot)
  end

  test "should park edit and cancel running round instead of truncating when busy" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    edited = create(:ai_message, ai_chat: ai_chat, role: "user", content: "original prompt")
    tail = create(:ai_message, ai_chat: ai_chat, role: "assistant", content: "partial answer")
    ai_chat.update_columns(processing: true)
    sign_in user

    assert_no_enqueued_jobs only: AIChatResponseJob do
      patch dashboard_post_ai_chat_message_url(user.account.name, post, ai_chat, edited), as: :turbo_stream, params: {
        ai_message: { content: "edited prompt" }
      }
    end

    assert_response :success
    assert_equal "edited prompt", edited.reload.content
    assert_equal edited.id, ai_chat.reload.restart_from_message_id
    assert_predicate ai_chat, :processing?
    assert_predicate ai_chat, :cancelled?
    assert AI::Message.exists?(tail.id)
  end

  test "should park edit while a cancelled round is still draining" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    edited = create(:ai_message, ai_chat: ai_chat, role: "user", content: "original prompt")
    ai_chat.update_columns(processing: false, cancelled: true)
    sign_in user

    patch dashboard_post_ai_chat_message_url(user.account.name, post, ai_chat, edited), as: :turbo_stream, params: {
      ai_message: { content: "edited prompt" }
    }

    assert_equal edited.id, ai_chat.reload.restart_from_message_id
    assert_predicate ai_chat, :processing?
  end

  test "should leave conversation untouched when edit content is blank" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    edited = create(:ai_message, ai_chat: ai_chat, role: "user", content: "original prompt")
    tail = create(:ai_message, ai_chat: ai_chat, role: "assistant", content: "old answer")
    sign_in user

    assert_no_enqueued_jobs only: AIChatResponseJob do
      patch dashboard_post_ai_chat_message_url(user.account.name, post, ai_chat, edited), as: :turbo_stream, params: {
        ai_message: { content: "" },
        snapshot: { title: "New title", content: "New body" }
      }
    end

    assert_response :no_content
    assert_equal "original prompt", edited.reload.content
    assert_equal({}, ai_chat.reload.snapshot)
    assert AI::Message.exists?(tail.id)
    assert_not_predicate ai_chat, :processing?
    assert_nil ai_chat.restart_from_message_id
  end

  test "should not edit an assistant message" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    assistant = create(:ai_message, ai_chat: ai_chat, role: "assistant", content: "old answer")
    sign_in user

    patch dashboard_post_ai_chat_message_url(user.account.name, post, ai_chat, assistant), as: :turbo_stream, params: {
      ai_message: { content: "edited" }
    }

    assert_response :not_found
    assert_equal "old answer", assistant.reload.content
    assert_no_enqueued_jobs only: AIChatResponseJob
  end

  test "should replace message row with edit form" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    edited = create(:ai_message, ai_chat: ai_chat, role: "user", content: "original prompt")
    sign_in user

    get edit_dashboard_post_ai_chat_message_url(user.account.name, post, ai_chat, edited), as: :turbo_stream

    assert_response :success
    assert_match(/edit_ai_message_#{edited.id}/, response.body)
  end

  test "should replace edit form back with the message row" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    edited = create(:ai_message, ai_chat: ai_chat, role: "user", content: "original prompt")
    sign_in user

    get dashboard_post_ai_chat_message_url(user.account.name, post, ai_chat, edited), as: :turbo_stream

    assert_response :success
    assert_match(/ai_message_#{edited.id}_content/, response.body)
    assert_match(/original prompt/, response.body)
  end

  test "should clear parked edit when creating a new message" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    ai_chat.update_columns(cancelled: true, restart_from_message_id: 1)
    sign_in user

    post dashboard_post_ai_chat_messages_url(user.account.name, post, ai_chat), as: :turbo_stream, params: {
      ai_message: { content: "Continue writing" }
    }

    assert_nil ai_chat.reload.restart_from_message_id
    assert_not_predicate ai_chat, :cancelled?
    assert_predicate ai_chat, :processing?
  end

  test "should ignore a new message while a round is generating" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    ai_chat.update_columns(processing: true)
    sign_in user

    assert_no_enqueued_jobs only: AIChatResponseJob do
      assert_no_difference "ai_chat.ai_messages.count" do
        post dashboard_post_ai_chat_messages_url(user.account.name, post, ai_chat), params: {
          ai_message: { content: "Continue writing" }
        }
      end
    end

    assert_response :no_content
  end

  test "should still accept a new message while a round is being cancelled" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    ai_chat.update_columns(processing: true, cancelled: true)
    sign_in user

    post dashboard_post_ai_chat_messages_url(user.account.name, post, ai_chat), as: :turbo_stream, params: {
      ai_message: { content: "Continue writing" }
    }

    assert_response :success
    assert_equal 1, ai_chat.ai_messages.count
    assert_not_predicate ai_chat.reload, :cancelled?
  end
end
