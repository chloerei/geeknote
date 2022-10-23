require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    create(:post)

    get root_path
    assert_response :success
  end

  test "should get feed" do
    user = create(:user)
    post = create(:post)
    user.follows.create(account: post.account)

    sign_in user
    get feed_path
    assert_response :success
  end

  test "should get newest" do
    create(:post)

    get newest_path
    assert_response :success
  end
end
