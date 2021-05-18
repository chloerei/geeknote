require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    create(:post)

    get root_path
    assert_response :success
  end

  test "should get following" do
    user = create(:user)
    post = create(:post)
    user.follows.create(account: post.account)

    sign_in user
    get following_posts_path
    assert_response :success
  end
end
