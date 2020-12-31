require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get sign up page" do
    get sign_up_url
    assert_response :success
  end

  test "should create user" do
    post users_url, params: { user: attributes_for(:user) }
    assert_redirected_to root_url
    assert current_user
  end
end
