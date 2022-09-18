require "test_helper"

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, email: ENV['ADMIN_EMAILS'])
    @account = create(:user_account)
    sign_in @admin
  end

  test "should get index" do
    get admin_accounts_path
    assert_response :success
  end

  test "should get edit post" do
    get edit_admin_account_path(@account.id)
    assert_response :success
  end

  test "should update post" do
    patch admin_account_path(@account.id), params: { account: { name: 'changed' } }
    assert_redirected_to edit_admin_account_path(@account.id)
    @account.reload
    assert_equal 'changed', @account.name
  end
end
