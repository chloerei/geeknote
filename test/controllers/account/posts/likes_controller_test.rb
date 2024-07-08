require "test_helper"

class Account::Posts::LikesControllerTest < ActionDispatch::IntegrationTest
  test "should like post" do
    user = create(:user)
    post = create(:post)

    sign_in user
    assert_difference "post.likes.count" do
      post account_post_like_path(post.account.name, post)
    end
    assert post.liked_by?(user)
  end

  test "should unlike post" do
    user = create(:user)
    post = create(:post)
    post.likes.create(user: user)

    sign_in user
    assert_difference "post.likes.count", -1 do
      delete account_post_like_path(post.account.name, post)
    end
    assert_not post.liked_by?(user)
  end
end
