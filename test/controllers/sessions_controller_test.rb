require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get sign in page" do
    get sign_in_url
    assert_response :success
  end

  test "should sign in with email password" do
    user = create(:user, email: "username@example.com", password: "password")
    post sign_in_path, params: { user: { email: "username@example.com", password: "password" } }
    assert_redirected_to root_url
    assert_equal user, current_user
  end

  test "should not sign in with wrong password" do
    user = create(:user, email: "username@example.com", password: "password")
    post sign_in_path, params: { user: { email: "username@example.com", password: "wrong" } }
    assert_nil current_user
  end

  test "should sign out" do
    user = create(:user)
    sign_in(user)
    delete sign_out_url
    assert_redirected_to root_url
    assert_nil current_user
  end
end
