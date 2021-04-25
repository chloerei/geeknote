require "test_helper"

class Account::InvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = create(:organization)
  end

  test "should get invitation by token" do
    invitation = create(:invitation, organization: @organization)
    get account_invitation_path(@organization.account, invitation_token: invitation.invitation_token)
    assert_response :success
  end

  test "should not get invitation by invalid token" do
    invitation = create(:invitation, organization: @organization)
    get account_invitation_path(@organization.account, invitation_token: 'notexists')
    assert_response :not_found
  end

  test "should not get invitation if expired" do
    invitation = create(:invitation, organization: @organization, invited_at: 1.month.ago)
    get account_invitation_path(@organization.account, invitation_token: invitation.invitation_token)
    assert_response :not_found
  end

  test "should get invitation by invited user" do
    user = create(:user)
    invitation = create(:invitation, organization: @organization, user: user)
    sign_in user
    get account_invitation_path(@organization.account)
    assert_response :success
  end

  test "should not get invitation by not invited user" do
    user = create(:user)
    sign_in user
    get account_invitation_path(@organization.account)
    assert_response :not_found
  end

  test "should not get user invitation by token" do
    user = create(:user)
    invitation = create(:invitation, organization: @organization, user: user)
    get account_invitation_path(@organization.account, invitation_token: invitation.invitation_token)
    assert_response :not_found
  end

  test "should accept invitation by token" do
    invitation = create(:invitation, organization: @organization)
    sign_in create(:user)
    assert_difference "@organization.memberships.active.count" do
      patch account_invitation_path(@organization.account, invitation_token: invitation.invitation_token)
    end
    assert_redirected_to account_dashboard_posts_path(@organization.account)
    invitation.reload
    assert invitation.active?
    assert current_user, invitation.user
  end

  test "should accept invitation by user" do
    user = create(:user)
    invitation = create(:invitation, organization: @organization, user: user)
    sign_in user
    assert_difference "@organization.memberships.active.count" do
      patch account_invitation_path(@organization.account)
    end
    assert_redirected_to account_dashboard_posts_path(@organization.account)
  end

  test "should not accept invitation if user not match" do
    user = create(:user)
    invitation = create(:invitation, organization: @organization, user: user)
    other_user = create(:user)
    sign_in other_user

    assert_no_difference "@organization.memberships.active.count" do
      patch account_invitation_path(@organization.account, invitation_token: invitation.invitation_token)
    end
    assert_response :not_found
  end

  test "should not accept invitation by member" do
    user = create(:membership, organization: @organization).user
    invitation = create(:invitation, organization: @organization)
    sign_in user

    assert_no_difference "@organization.memberships.active.count" do
      patch account_invitation_path(@organization.account, invitation_token: invitation.invitation_token)
    end
    assert_redirected_to account_invitation_path(@organization.account, invitation_token: invitation.invitation_token)
  end
end
