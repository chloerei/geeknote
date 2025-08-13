require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get sign in page" do
    get sign_in_url
    assert_response :success
  end

  test "should sign in with email password" do
    create(:user, email: "username@example.com", password: "password")
    post sign_in_path, params: { user: { email: "username@example.com", password: "password" } }
    assert_redirected_to root_url
  end

  test "should not sign in with wrong password" do
    create(:user, email: "username@example.com", password: "password")
    post sign_in_path, params: { user: { email: "username@example.com", password: "wrong" } }
    assert_response :unprocessable_entity
  end

  test "should sign out" do
    user = create(:user)
    sign_in(user)
    delete sign_out_url
    assert_redirected_to root_url
  end
end
