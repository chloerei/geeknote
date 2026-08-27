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
    RubyLLM.config.default_model = "deepseek-v4-flash"
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    sign_in user

    assert_difference "post.ai_chats.count", 1 do
      assert_difference "AI::Message.count", 1 do
        post dashboard_post_ai_chats_url(user.account.name, post), params: {
          ai_message: { content: "Help me write an opening" }
        }
      end
    end

    ai_chat = post.ai_chats.last
    assert_equal user, ai_chat.user
    assert_equal "deepseek-v4-flash", ai_chat.model_id
    assert_equal "user", ai_chat.ai_messages.last.role
    assert_equal "Help me write an opening", ai_chat.ai_messages.last.content
    assert_redirected_to dashboard_post_ai_chat_url(user.account.name, post, ai_chat)
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
end
