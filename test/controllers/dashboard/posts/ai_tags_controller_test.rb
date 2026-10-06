require "test_helper"

class Dashboard::Posts::AITagsControllerTest < ActionDispatch::IntegrationTest
  test "suggests tags for the submitted draft" do
    user = create(:user)
    sign_in user
    stub_ai_completion("ruby, rails")

    post ai_tags_dashboard_posts_url(user.account.name), params: {
      title: "A draft title",
      content: "A draft body"
    }

    assert_response :success
    assert_equal %w[ruby rails], response.parsed_body["tags"]
  end

  test "should redirect when not signed in" do
    user = create(:user)

    post ai_tags_dashboard_posts_url(user.account.name), params: { content: "Body" }

    assert_redirected_to new_session_url
  end

  test "should not suggest tags for another account" do
    user = create(:user)
    other_user = create(:user)
    sign_in user

    post ai_tags_dashboard_posts_url(other_user.account.name), params: { content: "Body" }

    assert_redirected_to account_root_path(other_user.account.name)
    assert_not_requested :post, AI_COMPLETION_URL
  end

  test "refuses the request when no model is configured" do
    user = create(:user)
    sign_in user

    with_default_model(nil) do
      post ai_tags_dashboard_posts_url(user.account.name), params: { content: "Body" }
    end

    assert_response :service_unavailable
    assert_not_requested :post, AI_COMPLETION_URL
  end

  test "reports a provider failure as a bad gateway" do
    user = create(:user)
    sign_in user
    stub_request(:post, AI_COMPLETION_URL).to_return(status: 400, body: "bad request")

    post ai_tags_dashboard_posts_url(user.account.name), params: { content: "Body" }

    assert_response :bad_gateway
    assert_equal I18n.t("dashboard.posts.ai_tags.create.failure"), response.parsed_body["error"]
  end
end
