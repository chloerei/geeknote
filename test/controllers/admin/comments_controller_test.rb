require "test_helper"

class Admin::CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, email: User::ADMIN_EMAILS.last)
    @comment = create(:comment)
    sign_in @admin
  end

  test "should get index" do
    get admin_comments_path
    assert_response :success
  end

  test "should get post" do
    get admin_comment_path(@comment)
    assert_response :success
  end

  test "should edit post" do
    get edit_admin_comment_path(@comment)
    assert_response :success
  end

  test "should update post" do
    patch admin_comment_path(@comment), params: { comment: { content: 'changed' } }
    assert_redirected_to admin_comment_path(@comment)
    @comment.reload
    assert_equal 'changed', @comment.content
  end
end
