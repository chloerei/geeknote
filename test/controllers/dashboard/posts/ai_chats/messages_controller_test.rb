require "test_helper"

class Dashboard::Posts::AIChats::MessagesControllerTest < ActionDispatch::IntegrationTest
  test "should enqueue response job on message" do
    user = create(:user)
    post = create(:post, account: user.account, user: user)
    ai_chat = create(:ai_chat, post: post, user: user)
    sign_in user

    assert_enqueued_with(job: AIChatResponseJob) do
      post dashboard_post_ai_chat_messages_url(user.account.name, post, ai_chat), params: {
        ai_message: { content: "Continue writing" }
      }
    end

    assert_redirected_to dashboard_post_ai_chat_url(user.account.name, post, ai_chat)
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
end
