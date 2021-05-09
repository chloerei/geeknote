require "test_helper"

class Account::LikesControllerTest < ActionDispatch::IntegrationTest
  test "should get like posts" do
    user = create(:user)
    post = create(:post)
    post.likes.create(user: user)

    get account_likes_path(user.account)
    assert_response :success
  end
end
