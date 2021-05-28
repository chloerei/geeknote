require "test_helper"

class Account::Posts::BookmarksControllerTest < ActionDispatch::IntegrationTest
  test "should create bookmark" do
    user = create(:user)
    post = create(:post)

    sign_in user
    assert_difference "user.bookmarks.count" do
      post account_post_bookmark_path(post.account, post), as: :turbo_stream
    end
  end

  test "should destroy bookmark" do
    user = create(:user)
    post = create(:post)

    user.bookmarks.create(post: post)
    sign_in user
    assert_difference "user.bookmarks.count", -1 do
      delete account_post_bookmark_path(post.account, post), as: :turbo_stream
    end
  end
end
