require "test_helper"

class Explore::PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    create(:post)

    get explore_root_path
    assert_response :success
  end

  test "should get feed" do
    user = create(:user)
    post = create(:post)
    user.follows.create(account: post.account)

    sign_in user
    get explore_feed_path
    assert_response :success
  end

  test "should get newest" do
    create(:post)

    get explore_newest_path
    assert_response :success
  end

end
