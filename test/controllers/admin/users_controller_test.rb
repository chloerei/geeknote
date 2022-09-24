require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, email: ENV['ADMIN_EMAILS'])
    @user = create(:user)
    sign_in @admin
  end

  test "should get index" do
    get admin_users_path
    assert_response :success
  end

  test "should get post" do
    get admin_user_path(@user)
    assert_response :success
  end

  test "should edit post" do
    get edit_admin_user_path(@user)
    assert_response :success
  end

  test "should update post" do
    patch admin_user_path(@user), params: { user: { name: 'changed' } }
    assert_redirected_to admin_user_path(@user)
    @user.reload
    assert_equal 'changed', @user.name
  end
end
