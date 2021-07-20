require "test_helper"

class Account::Dashboard::Posts::SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should remove authors" do
    account = create(:organization_account)
    user = create(:user)
    account.owner.members.create(user: user, status: :active)
    post = create(:post, account: account, author_users: [user])

    sign_in user

    assert post.authors.any?
    patch account_dashboard_post_settings_path(account, post), params: { post: { excerpt: '' }}
    post.reload
    assert post.authors.empty?
  end

  test "should set tags" do
    account = create(:organization_account)
    user = create(:user)
    account.owner.members.create(user: user, status: :active, role: 'owner')
    post = create(:post, account: account, author_users: [user])

    sign_in user

    patch account_dashboard_post_settings_path(account, post), params: { post: { tag_list: ['Ruby', 'JavaScript'] }}
    post.reload
    assert_equal ['Ruby', 'JavaScript'], post.tag_list

    patch account_dashboard_post_settings_path(account, post), params: { post: { tag_list: ['Ruby'] }}
    post.reload
    assert_equal ['Ruby'], post.tag_list

    patch account_dashboard_post_settings_path(account, post), params: { post: { excerpt: '' }}
    post.reload
    assert_equal [], post.tag_list
  end
end
