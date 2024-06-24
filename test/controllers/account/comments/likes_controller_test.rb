require "test_helper"

class Account::Comments::LikesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @comment = create(:comment)
    @user = create(:user)
    sign_in @user
  end

  test "should create like" do
    assert_difference "@comment.likes.count" do
      post account_comment_like_url(@comment.user.account.name, @comment)
    end
    assert_response :success
  end

  test "should destroy like" do
    create(:like, likable: @comment, user: @user)

    assert_difference "@comment.likes.count", -1 do
      delete account_comment_like_url(@comment.user.account.name, @comment)
    end
    assert_response :success
  end
end
