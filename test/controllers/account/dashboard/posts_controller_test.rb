require "test_helper"

class Account::Dashboard::PostsControllerTest < ActionDispatch::IntegrationTest
  test "should not get other account posts" do
    user = create(:user)
    other = create(:user)
    create(:post, account: user.account, user: user)

    sign_in other
    get account_dashboard_posts_url(user.account)
    assert_response :not_found

    sign_in user
    get account_dashboard_posts_url(user.account)
    assert_response :success
    assert_select '.post-item', 1
  end

  test "should get org account posts" do
    organization = create(:organization)
    nobody = create(:user)
    member = create(:member, organization: organization, role: 'member').user
    admin = create(:member, organization: organization, role: 'admin').user
    create(:post, account: organization.account, user: member)
    create(:post, account: organization.account)

    sign_in nobody
    get account_dashboard_posts_url(organization.account)
    assert_response :not_found

    sign_in member
    get account_dashboard_posts_url(organization.account)
    assert_response :success
    assert_select '.post-item', 1

    sign_in admin
    get account_dashboard_posts_url(organization.account)
    assert_response :success
    assert_select '.post-item', 2
  end

  test "should get new page as user" do
    user = create(:user)
    sign_in user
    get new_account_dashboard_post_path(user.account)
    assert_response :success
  end

  test "should get new page as org" do
    organization = create(:organization)
    user = create(:member, organization: organization, role: 'member').user

    sign_in user
    get new_account_dashboard_post_path(organization.account)
    assert_response :success
  end

  test "should create post as user" do
    user = create(:user)
    sign_in user
    assert_difference "user.account.posts.count" do
      post account_dashboard_posts_path(user.account), params: { post: { title: '' }}, as: :turbo_stream
    end
    last_post = user.account.posts.last
    assert_redirected_to account_post_url(user.account, last_post)
    assert_equal user, last_post.user
  end

  test "should create post as member" do
    organization = create(:organization)
    user = create(:member, organization: organization).user

    sign_in user
    assert_difference "organization.account.posts.count" do
      post account_dashboard_posts_path(organization.account), params: { post: { title: '' }}, as: :turbo_stream
    end
    last_post = organization.account.posts.last
    assert_redirected_to account_post_url(organization.account, last_post)
    assert_equal user, last_post.user
  end

  test "should get edit page as user" do
    user = create(:user)
    one_post = create(:post, account: user.account, user: user)
    sign_in user
    get edit_account_dashboard_post_path(user.account, one_post)
    assert_response :success
  end

  test "should get edit post as author or admin" do
    organization = create(:organization)
    user = create(:user)
    member = create(:member, organization: organization, role: 'member').user
    admin = create(:member, organization: organization, role: 'admin').user

    member_post = create(:post, account: organization.account, user: member)
    other_post = create(:post, account: organization.account)

    get edit_account_dashboard_post_path(organization.account, member_post)
    assert_response :redirect

    sign_in user
    get edit_account_dashboard_post_path(organization.account, member_post)
    assert_response :not_found

    sign_in member
    get edit_account_dashboard_post_path(organization.account, member_post)
    assert_response :success
    assert_raise(ActiveRecord::RecordNotFound) do
      get edit_account_dashboard_post_path(organization.account, other_post)
    end

    sign_in admin
    get edit_account_dashboard_post_path(organization.account, member_post)
    assert_response :success
    get edit_account_dashboard_post_path(organization.account, other_post)
    assert_response :success
  end

  test "should update post as author or admin" do
    organization = create(:organization)
    nobody = create(:user)
    member = create(:member, organization: organization, role: 'member').user
    admin = create(:member, organization: organization, role: 'admin').user

    member_post = create(:post, account: organization.account, user: member)
    other_post = create(:post, account: organization.account)

    patch account_dashboard_post_path(organization.account, member_post), params: { post: { title: 'change by none' }}, as: :turbo_stream
    assert_response :redirect

    sign_in nobody
    patch account_dashboard_post_path(organization.account, member_post), params: { post: { title: 'change by nobody' }}, as: :turbo_stream
    assert_response :not_found

    sign_in member
    patch account_dashboard_post_path(organization.account, member_post), params: { post: { title: 'change by member' }}, as: :turbo_stream
    assert_redirected_to account_post_url(organization.account, member_post)
    assert_raise ActiveRecord::RecordNotFound do
      patch account_dashboard_post_path(organization.account, other_post), params: { post: { title: 'change by member' }}, as: :turbo_stream
    end

    sign_in admin
    patch account_dashboard_post_path(organization.account, member_post), params: { post: { title: 'change by admin' }}, as: :turbo_stream
    assert_redirected_to account_post_url(organization.account, member_post)
    patch account_dashboard_post_path(organization.account, other_post), params: { post: { title: 'change by admin' }}, as: :turbo_stream
    assert_redirected_to account_post_url(organization.account, other_post)
  end

  test "should not publish restricted post" do
    account = create(:user_account)
    post = create(:post, account: account, user: account.owner, restricted: true)

    sign_in account.owner

    patch account_dashboard_post_path(account, post), params: { post: { title: 'title' }, submit: 'publish'}
    post.reload
    assert_not post.published?
  end
end
