require "test_helper"

class Dashboard::Posts::TrashesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @post = create(:post, account: @user.account, user: @user)
  end

  test "should trash post" do
    sign_in @user
    patch dashboard_post_trash_url(@post.account.name, @post)
    @post.reload
    assert @post.trashed?
  end

  test "should untrash post" do
    sign_in @user
    @post.trashed!
    delete dashboard_post_trash_url(@post.account.name, @post)
    @post.reload
    assert @post.draft?
  end
end
