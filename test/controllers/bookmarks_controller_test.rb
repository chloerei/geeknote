require "test_helper"

class BookmarksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @post = create(:post)
  end

  test "should get index" do
    sign_in @user
    create(:bookmark, user: @user, post: @post)
    get bookmarks_url
    assert_response :success
  end
end
