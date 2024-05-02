require "test_helper"

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, email: User::ADMIN_EMAILS.last)
    @account = create(:user_account)
    sign_in @admin
  end

  test "should get index" do
    get admin_accounts_path
    assert_response :success
  end

  test "should get post" do
    get admin_account_path(@account.id)
    assert_response :success
  end

  test "should edit post" do
    get edit_admin_account_path(@account.id)
    assert_response :success
  end

  test "should update post" do
    patch admin_account_path(@account.id), params: { account: { name: "changed" } }
    assert_redirected_to admin_account_path(@account.id)
    @account.reload
    assert_equal "changed", @account.name
  end
end
