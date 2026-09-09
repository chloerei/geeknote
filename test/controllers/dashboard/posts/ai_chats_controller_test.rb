require "test_helper"

class Dashboard::Posts::AIChatsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    chat = create(:ai_chat, post: post, user: user)
    create(:ai_message, ai_chat: chat, role: "user", content: "Help me write an opening")
    sign_in user

    get dashboard_post_ai_chats_url(user.account.name, post)
    assert_response :success
  end

  test "should not get index of other post" do
    user = create(:user)
    post = create(:post)
    sign_in user

    get dashboard_post_ai_chats_url(user.account.name, post)
    assert_response :not_found
  end

  test "should redirect when not signed in" do
    user = create(:user)
    post = create(:post, user: user, account: user.account)

    get dashboard_post_ai_chats_url(user.account.name, post)
    assert_redirected_to new_session_url
  end

  test "should create chat" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    sign_in user

    assert_difference "post.ai_chats.count", 1 do
      assert_difference "AI::Message.count", 1 do
        assert_enqueued_with(job: AIChatTitleJob) do
          post dashboard_post_ai_chats_url(user.account.name, post), params: {
            ai_message: { content: "Help me write an opening" }
          }
        end
      end
    end

    ai_chat = post.ai_chats.last
    assert_equal user, ai_chat.user
    assert_equal "deepseek-v4-flash", ai_chat.model_id
    assert_nil ai_chat.title
    assert_equal "user", ai_chat.ai_messages.last.role
    assert_equal "Help me write an opening", ai_chat.ai_messages.last.content
    assert_predicate ai_chat, :processing?
    assert_redirected_to dashboard_post_ai_chat_url(user.account.name, post, ai_chat)
  end

  test "should create chat with snapshot" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    sign_in user

    assert_difference "post.ai_chats.count", 1 do
      assert_difference "AI::Message.count", 1 do
        post dashboard_post_ai_chats_url(user.account.name, post), params: {
          ai_message: { content: "Help me write an opening" },
          snapshot: { title: "Draft title", content: "Draft body" }
        }
      end
    end

    ai_chat = post.ai_chats.last
    assert_equal({ "title" => "Draft title", "content" => "Draft body" }, ai_chat.snapshot)
  end

  test "should not create chat without content" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    sign_in user

    assert_no_difference "post.ai_chats.count" do
      post dashboard_post_ai_chats_url(user.account.name, post), params: {
        ai_message: { content: "" }
      }
    end

    assert_response :no_content
  end

  test "should show chat" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    sign_in user

    get dashboard_post_ai_chat_url(user.account.name, post, ai_chat)
    assert_response :success
  end

  test "should show chat with messages" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    create(:ai_message, ai_chat: ai_chat, role: "user", content: "Help me write an opening")
    create(:ai_message, ai_chat: ai_chat, role: "assistant", content: "Sure, here is the opening")
    sign_in user

    get dashboard_post_ai_chat_url(user.account.name, post, ai_chat)
    assert_response :success
  end

  test "should not show chat of other post" do
    user = create(:user)
    post = create(:post)
    ai_chat = create(:ai_chat, post: post, user: post.user)
    sign_in user

    get dashboard_post_ai_chat_url(user.account.name, post, ai_chat)
    assert_response :not_found
  end

  test "should destroy chat" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    sign_in user

    assert_difference "post.ai_chats.count", -1 do
      delete dashboard_post_ai_chat_url(user.account.name, post, ai_chat)
    end

    assert_redirected_to dashboard_post_ai_chats_url(user.account.name, post)
  end

  test "should cancel chat generation" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    ai_chat.update_columns(processing: true)
    sign_in user

    post cancel_dashboard_post_ai_chat_url(user.account.name, post, ai_chat), as: :turbo_stream

    assert_response :success
    assert_predicate ai_chat.reload, :cancelled?
    assert_not_predicate ai_chat.reload, :processing?
  end

  test "should clear parked edit when cancelling generation" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    ai_chat.update_columns(processing: true, restart_from_message_id: 42)
    sign_in user

    post cancel_dashboard_post_ai_chat_url(user.account.name, post, ai_chat), as: :turbo_stream

    assert_predicate ai_chat.reload, :cancelled?
    assert_nil ai_chat.reload.restart_from_message_id
  end

  test "should clear parked edit when creating a chat" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    sign_in user

    post dashboard_post_ai_chats_url(user.account.name, post), params: {
      ai_message: { content: "Help me write an opening" }
    }

    ai_chat = post.ai_chats.last
    assert_nil ai_chat.restart_from_message_id
  end

  test "should redirect after cancelling chat generation for html requests" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    sign_in user

    post cancel_dashboard_post_ai_chat_url(user.account.name, post, ai_chat)

    assert_redirected_to dashboard_post_ai_chat_url(user.account.name, post, ai_chat)
    assert_predicate ai_chat.reload, :cancelled?
  end

  test "should not cancel chat of other post" do
    user = create(:user)
    post = create(:post)
    ai_chat = create(:ai_chat, post: post, user: post.user)
    sign_in user

    post cancel_dashboard_post_ai_chat_url(user.account.name, post, ai_chat)
    assert_response :not_found
  end
end
