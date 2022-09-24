require "test_helper"

class Admin::PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, email: ENV['ADMIN_EMAILS'])
    @post = create(:post)
    sign_in @admin
  end

  test "should get index" do
    create(:post)

    get admin_posts_path
    assert_response :success
  end

  test "should get post" do
    get admin_post_path(@post)
    assert_response :success
  end

  test "should edit post" do
    get edit_admin_post_path(@post)
    assert_response :success
  end

  test "should update post" do
    patch admin_post_path(@post), params: { post: { title: 'changed' } }
    assert_redirected_to edit_admin_post_path(@post)
    @post.reload
    assert_equal 'changed', @post.title
  end

  test "should restrict post" do
    patch restrict_admin_post_path(@post)
    assert_redirected_to admin_post_path(@post)
    @post.reload
    assert @post.restricted?
  end

  test "should unrestrict post" do
    @post.restricted!

    patch unrestrict_admin_post_path(@post)
    assert_redirected_to admin_post_path(@post)
    @post.reload
    assert_not @post.restricted?
  end
end
