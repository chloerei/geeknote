require "test_helper"

class Account::CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = create(:post)
    @user = create(:user)
    sign_in @user
  end

  test "should create comment" do
    assert_difference("Comment.count") do
      post account_comments_url(@user.account.name), params: { comment: { content: "Content", commentable_sgid: @post.to_sgid(for: :commentable) } }
    end
    assert_response :success
    comment = Comment.last
    assert_equal @post, comment.commentable
  end

  test "should create with parent" do
    comment = create(:comment, commentable: @post)

    assert_difference("Comment.count") do
      post account_comments_url(@user.account.name), params: { comment: { content: "Content", commentable_sgid: @post.to_sgid(for: :commentable), parent_id: comment.id } }
    end
    assert_response :success
    last_comment = Comment.last
    assert_equal @post, last_comment.commentable
    assert_equal comment, last_comment.parent
  end

  test "should get show" do
    comment = create(:comment, commentable: @post, user: @user)
    get account_comment_url(@user.account.name, comment)
    assert_response :success
  end

  test "should get edit" do
    comment = create(:comment, commentable: @post, user: @user)
    get edit_account_comment_url(@user.account.name, comment)
    assert_response :success
  end

  test "should update comment" do
    comment = create(:comment, commentable: @post, user: @user)
    patch account_comment_url(@user.account.name, comment), params: { comment: { content: "New content" } }
    assert_redirected_to account_comment_url(@user.account.name, comment)
  end

  test "should destroy comment" do
    comment = create(:comment, commentable: @post, user: @user)
    assert_difference("Comment.count", -1) do
      delete account_comment_url(@user.account.name, comment)
    end
    assert_response :success
  end
end
