require "test_helper"

class BookmarksControllerTest < ActionDispatch::IntegrationTest
  test "should get bookmark index" do
    user = create(:user)
    create(:bookmark, user: user)

    sign_in user
    get bookmarks_path
    assert_response :success
  end

  test "should get archived bookmarks" do
    user = create(:user)
    create(:bookmark, user: user, status: :archived)

    sign_in user
    get archived_bookmarks_path
    assert_response :success
  end

  test "should archive bookmark" do
    user = create(:user)
    bookmark = create(:bookmark, user: user)

    sign_in user
    assert_difference "user.bookmarks.archived.count" do
      patch bookmark_path(bookmark), params: { bookmark: { status: 'archived' } }
    end
  end

  test "should unarchive bookmark" do
    user = create(:user)
    bookmark = create(:bookmark, user: user, status: :archived)

    sign_in user
    assert_difference "user.bookmarks.archived.count", -1 do
      patch bookmark_path(bookmark), params: { bookmark: { status: 'saved' } }
    end
  end

  test "should delete bookmark" do
    user = create(:user)
    bookmark = create(:bookmark, user: user)

    sign_in user
    assert_difference "user.bookmarks.count", -1 do
      delete bookmark_path(bookmark)
    end
  end
end
