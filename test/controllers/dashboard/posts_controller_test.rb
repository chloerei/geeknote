require "test_helper"

class Dashboard::PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index in personal" do
    user = create(:user)
    create(:post, user: user)
    create(:post)
    sign_in user

    get dashboard_posts_url(user.account.name)
    assert_response :success
  end

  test "should get index in org as admin" do
    user = create(:user)
    organization = create(:organization)
    create(:member, user: user, organization: organization, role: "admin")
    sign_in user

    create(:post, account: organization.account, user: user)
    create(:post, account: organization.account)

    get dashboard_posts_url(organization.account.name)
    assert_response :success
  end

  test "should get index in org as member" do
    user = create(:user)
    organization = create(:organization)
    create(:member, user: user, organization: organization, role: "member")
    sign_in user

    create(:post, account: organization.account, user: user)
    create(:post, account: organization.account)

    get dashboard_posts_url(organization.account.name)
    assert_response :success
  end

  test "should get new" do
    user = create(:user)
    sign_in user

    get new_dashboard_post_url(user.account.name)
    assert_response :success
  end

  test "should create post" do
    user = create(:user)
    sign_in user

    assert_difference "user.posts.count" do
      post dashboard_posts_url(user.account.name), params: { post: { title: "Title", content: "Content" } }
    end

    assert_redirected_to edit_dashboard_post_url(user.account.name, Post.last)
  end

  test "should get edit as personal" do
    user = create(:user)
    post = create(:post, user: user)
    sign_in user

    get edit_dashboard_post_url(user.account.name, post)
    assert_response :success
  end

  test "should not get other edit as personal" do
    user = create(:user)
    post = create(:post)
    sign_in user

    get edit_dashboard_post_url(user.account.name, post)
    assert_response :not_found
  end

  test "should get edit as admin" do
    user = create(:user)
    organization = create(:organization)
    create(:member, user: user, organization: organization, role: "admin")
    post = create(:post, account: organization.account)
    sign_in user

    get edit_dashboard_post_url(organization.account.name, post)
    assert_response :success
  end

  test "should get edit as member" do
    user = create(:user)
    organization = create(:organization)
    create(:member, user: user, organization: organization, role: "member")
    post = create(:post, account: organization.account, user: user)
    sign_in user

    get edit_dashboard_post_url(organization.account.name, post)
    assert_response :success
  end

  test "should not get other edit as member" do
    user = create(:user)
    organization = create(:organization)
    create(:member, user: user, organization: organization, role: "member")
    post = create(:post, account: organization.account)
    sign_in user

    get edit_dashboard_post_url(organization.account.name, post)
    assert_response :not_found
  end

  test "should update post" do
    user = create(:user)
    post = create(:post, user: user)
    sign_in user

    patch dashboard_post_url(user.account.name, post), params: { post: { title: "New Title" } }
    assert_redirected_to edit_dashboard_post_url(user.account.name, post)
    assert_equal "New Title", post.reload.title
  end
end
