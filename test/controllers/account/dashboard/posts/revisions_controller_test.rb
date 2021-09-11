require "test_helper"

class Account::Dashboard::Posts::RevisionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = create(:user_account)
    @user = @account.owner
    @post = create(:post, account: @account, author_users: [@user])
  end

  test "should get revision index" do
    sign_in @user
    get account_dashboard_post_revisions_path(@account, @post)
    assert_response :success
  end

   test "should get revision" do
     revision = create(:post_revision, post: @post, user: @user)

     sign_in @user
     get account_dashboard_post_revision_path(@account, @post, revision)
     assert_response :success
   end

   test "should restore revision" do
     revision = create(:post_revision, post: @post, user: @user, title: 'revision title', content: 'revision content')

     sign_in @user
     patch restore_account_dashboard_post_revision_path(@account, @post, revision)
     assert_redirected_to edit_account_dashboard_post_path(@account, @post)
     @post.reload
     assert_equal 'revision title', @post.title
     assert_equal 'revision content', @post.content
   end
end
