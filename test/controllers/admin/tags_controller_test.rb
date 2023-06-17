require "test_helper"

class Admin::TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, email: User::ADMIN_EMAILS.last)
    @tag = create(:tag)
    sign_in @admin
  end

  test "should get index" do
    get admin_tags_path
    assert_response :success
  end

  test "should get post" do
    get admin_tag_path(@tag)
    assert_response :success
  end

  test "should edit post" do
    get edit_admin_tag_path(@tag)
    assert_response :success
  end

  test "should update post" do
    patch admin_tag_path(@tag), params: { tag: { name: 'changed' } }
    assert_redirected_to admin_tag_path(@tag)
    @tag.reload
    assert_equal 'changed', @tag.name
  end
end
