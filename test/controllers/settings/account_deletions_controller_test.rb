require "test_helper"

class Settings::AccountDeletionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "should get show" do
    sign_in @user
    get settings_account_deletion_path
    assert_response :success
  end

  test "should schedule account deletion with matching account name and destroy session" do
    sign_in @user
    session = @user.sessions.last

    assert_enqueued_with(job: UserDeletionJob, args: [ @user ]) do
      post settings_account_deletion_path, params: { name: @user.account.name }
    end

    assert_redirected_to account_deleted_url
    assert_not Session.exists?(session.id)
    assert User.exists?(@user.id)
  end

  test "should not schedule deletion with mismatched account name" do
    sign_in @user
    session = @user.sessions.last

    assert_no_enqueued_jobs only: UserDeletionJob do
      post settings_account_deletion_path, params: { name: "wrong-name" }
    end

    assert_response :unprocessable_content
    assert Session.exists?(session.id)
    assert User.exists?(@user.id)
  end

  test "should not show deletion form when user belongs to an organization" do
    organization = create(:organization, name: "Test Org")
    create(:member, organization: organization, user: @user)
    sign_in @user

    get settings_account_deletion_path
    assert_response :success
    assert_select "form[action=?]", settings_account_deletion_path, count: 0
  end

  test "should not schedule deletion when user belongs to an organization" do
    organization = create(:organization)
    create(:member, organization: organization, user: @user)
    sign_in @user
    session = @user.sessions.last

    assert_no_enqueued_jobs only: UserDeletionJob do
      post settings_account_deletion_path, params: { name: @user.account.name }
    end

    assert_response :unprocessable_content
    assert Session.exists?(session.id)
    assert User.exists?(@user.id)
  end

  test "should require authentication" do
    get settings_account_deletion_path
    assert_redirected_to new_session_url
  end
end
