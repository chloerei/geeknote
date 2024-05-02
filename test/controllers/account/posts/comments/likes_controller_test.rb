require "test_helper"

class Account::Posts::Comments::LikesControllerTest < ActionDispatch::IntegrationTest
  test "should like post" do
    user = create(:user)
    post = create(:post)
    comment = create(:comment, account: post.account, commentable: post)

    sign_in user
    assert_difference "comment.likes.count" do
      post account_post_comment_like_path(post.account, post, comment)
    end
    assert comment.liked_by?(user)
  end

  test "should unlike post" do
    user = create(:user)
    post = create(:post)
    comment = create(:comment, account: post.account, commentable: post)
    comment.likes.create(user: user)

    sign_in user
    assert_difference "comment.likes.count", -1 do
      delete account_post_comment_like_path(post.account, post, comment)
    end
    assert_not post.liked_by?(user)
  end
end
