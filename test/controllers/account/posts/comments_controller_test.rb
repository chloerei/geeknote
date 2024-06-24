require "test_helper"

class Account::Posts::CommentsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @account = create(:user_account)
    @post = create(:post, account: @account)
    @comment = create(:comment, commentable: @post)
  end

  test "should get comments" do
    get account_post_comments_path(@account, @post)
    assert_response :success
  end
end
