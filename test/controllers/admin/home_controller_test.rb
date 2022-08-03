require "test_helper"

class Admin::HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index as admin" do
    user = create(:user, email: ENV['ADMIN_EMAILS'])
    sign_in user
    get admin_root_path
    assert_response :success
  end

  test "should not get index as user" do
    user = create(:user)
    sign_in user
    get admin_root_path
    assert_response :not_found
  end
end
