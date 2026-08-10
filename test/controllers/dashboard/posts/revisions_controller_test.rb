require "test_helper"

class Dashboard::Posts::RevisionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    user = create(:user)
    post = create(:post, user: user, account: user.account)
    post.update(title: "New title")
    sign_in user

    get dashboard_post_revisions_url(user.account.name, post)
    assert_response :success
  end

  test "should not get index of other post" do
    user = create(:user)
    post = create(:post)
    sign_in user

    get dashboard_post_revisions_url(user.account.name, post)
    assert_response :not_found
  end

  test "should redirect when not signed in" do
    user = create(:user)
    post = create(:post, user: user, account: user.account)

    get dashboard_post_revisions_url(user.account.name, post)
    assert_redirected_to new_session_url
  end

  test "should get show" do
    user = create(:user)
    post = create(:post, user: user, account: user.account)
    post.update(title: "New title")
    sign_in user

    get dashboard_post_revision_url(user.account.name, post, post.revisions.last)
    assert_response :success
  end

  test "should not get show of other post" do
    user = create(:user)
    post = create(:post)
    revision = create(:post_revision, post: post)
    sign_in user

    get dashboard_post_revision_url(user.account.name, post, revision)
    assert_response :not_found
  end

  test "should restore revision" do
    user = create(:user)
    post = create(:post, user: user, account: user.account, title: "Original title")
    post.update(title: "Changed title")
    revision = post.revisions.order(:id).first
    sign_in user

    assert_difference "post.revisions.count" do
      patch restore_dashboard_post_revision_url(user.account.name, post, revision)
    end

    assert_redirected_to edit_dashboard_post_url(user.account.name, post)
    assert_equal "Original title", post.reload.title
  end

  test "should not restore revision of other post" do
    user = create(:user)
    post = create(:post)
    revision = create(:post_revision, post: post)
    sign_in user

    patch restore_dashboard_post_revision_url(user.account.name, post, revision)
    assert_response :not_found
  end
end
