require "test_helper"

class Admin::CollectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, email: User::ADMIN_EMAILS.last)
    @collection = create(:collection)
    sign_in @admin
  end

  test "should get index" do
    get admin_collections_path
    assert_response :success
  end

  test "should get post" do
    get admin_collection_path(@collection)
    assert_response :success
  end

  test "should edit post" do
    get edit_admin_collection_path(@collection)
    assert_response :success
  end

  test "should update post" do
    patch admin_collection_path(@collection), params: { collection: { name: "changed" } }
    assert_redirected_to admin_collection_path(@collection)
    @collection.reload
    assert_equal "changed", @collection.name
  end
end
