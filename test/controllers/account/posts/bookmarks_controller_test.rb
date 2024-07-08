require "test_helper"

class Account::Posts::BookmarksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @post = create(:post)
  end

  test "should create bookmark" do
    sign_in @user
    assert_difference("@post.bookmarks.count") do
      post account_post_bookmark_url(@post.account.name, @post)
    end
    assert_response :success
  end

  test "should destroy bookmark" do
    sign_in @user
    @post.bookmarks.create(user: @user)
    assert_difference("@post.bookmarks.count", -1) do
      delete account_post_bookmark_url(@post.account.name, @post)
    end
    assert_response :success
  end
end
