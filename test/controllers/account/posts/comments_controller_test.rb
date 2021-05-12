require "test_helper"

class Account::Posts::CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = create(:user_account)
    @post = create(:post, account: @account)
    @comment = create(:comment, commentable: @post, account: @account)
  end

  test "should get comments" do
    get account_post_comments_path(@account, @post)
    assert_response :success
  end

  test "should get comment detail" do
    get account_post_comment_path(@account, @post, @comment)
    assert_response :success
  end

  test "should create comment" do
    sign_in create(:user)
    assert_difference "@post.comments.count" do
      post account_post_comments_path(@account, @post), params: { comment: { content: 'text' } }, as: :turbo_stream
    end
  end

  test "should reply comment" do
    sign_in create(:user)

    assert_difference ["@post.comments.count", "@comment.replies.count"] do
      post account_post_comments_path(@account, @post), params: { comment: { content: 'text', parent_id: @comment.id } }, as: :turbo_stream
    end
  end

  test "should edit comment" do
    sign_in create(:user)
    get edit_account_post_comment_path(@account, @post, @comment)
    assert_response :not_found

    sign_in @comment.user
    get edit_account_post_comment_path(@account, @post, @comment)
    assert_response :success
  end

  test "should update comment" do
    sign_in create(:user)
    patch account_post_comment_path(@account, @post, @comment), params: { comment: { content: 'change' } }
    assert_response :not_found

    sign_in @comment.user
    patch account_post_comment_path(@account, @post, @comment), params: { comment: { content: 'change' } }
    assert_redirected_to account_post_comment_path(@account, @post, @comment)
  end

  test "should destroy comment" do
    sign_in create(:user)
    delete account_post_comment_path(@account, @post, @comment)
    assert_response :not_found

    sign_in @comment.user
    delete account_post_comment_path(@account, @post, @comment)
    assert_response :success
  end
end
