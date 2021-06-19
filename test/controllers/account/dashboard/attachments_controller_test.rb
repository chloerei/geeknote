require "test_helper"

class Account::Dashboard::AttachmentsControllerTest < ActionDispatch::IntegrationTest
  test "should create attachment by user" do
    user = create(:user)

    assert_no_difference "user.account.attachments.count" do
      post account_dashboard_attachments_path(user.account), params: { attachment: { file: fixture_file_upload('avatar.png') } }
      assert_response :redirect
    end

    sign_in user

    assert_difference "user.account.attachments.count" do
      post account_dashboard_attachments_path(user.account), params: { attachment: { file: fixture_file_upload('avatar.png') } }
      assert_response :success
    end
    attachment = user.account.attachments.last
    assert_equal user, attachment.user
  end

  test "should create attachment by org member" do
    organization = create(:organization)

    assert_no_difference "organization.account.attachments.count" do
      post account_dashboard_attachments_path(organization.account), params: { attachment: { file: fixture_file_upload('avatar.png') } }
      assert_response :redirect
    end

    sign_in create(:user)
    assert_no_difference "organization.account.attachments.count" do
      post account_dashboard_attachments_path(organization.account), params: { attachment: { file: fixture_file_upload('avatar.png') } }
      assert_response :not_found
    end

    sign_in create(:member, organization: organization).user
    assert_difference "organization.account.attachments.count" do
      post account_dashboard_attachments_path(organization.account), params: { attachment: { file: fixture_file_upload('avatar.png') } }
      assert_response :success
    end
    attachment = organization.account.attachments.last
    assert_equal current_user, attachment.user
  end
end
