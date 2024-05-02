require "test_helper"

class Account::Dashboard::MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = create(:organization)
    @account = @organization.account
  end

  test "editor can visit member dashboard" do
    sign_in create(:user)
    get account_dashboard_members_path(@account)
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'member').user
    get account_dashboard_members_path(@account)
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'admin').user
    get account_dashboard_members_path(@account)
    assert_response :success
  end

  test "invite member" do
    sign_in create(:user)
    post account_dashboard_members_path(@account), params: { member: { invitation_email: 'account@example.com' } }
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'member').user
    post account_dashboard_members_path(@account), params: { member: { invitation_email: 'account@example.com' } }
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'admin').user
    assert_emails 1 do
      assert_difference "@organization.members.count" do
        post account_dashboard_members_path(@account), params: { member: { invitation_email: 'writer@example.com' } }
      end
    end
    assert_redirected_to account_dashboard_member_path(@account, @organization.members.last)
    assert 'member', @organization.members.last.role
    assert_equal current_user, @organization.members.last.inviter
    assert_not_nil @organization.members.last.invited_at
  end

  test "view member detail" do
    member = create(:member, organization: @organization, role: 'member')

    sign_in create(:user)
    get account_dashboard_member_path(@account, member)
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'member').user
    get account_dashboard_member_path(@account, member)
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'admin').user
    get account_dashboard_member_path(@account, member)
    assert_response :success
  end

  test "remove member" do
    member = create(:member, organization: @organization, role: 'member')

    sign_in create(:user)
    delete account_dashboard_member_path(@account, member)
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'member').user
    delete account_dashboard_member_path(@account, member)
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'admin').user
    assert_difference "@organization.members.count", -1 do
      delete account_dashboard_member_path(@account, member)
    end
    assert_redirected_to account_dashboard_members_path(@account)
  end

  test "should resend for expired invitation" do
    member = create(:invitation, organization: @organization)

    sign_in create(:member, organization: @organization, role: 'admin').user
    old_token = member.invitation_token
    post resend_account_dashboard_member_path(@account, member)
    member.reload
    assert_equal old_token, member.invitation_token

    travel_to 8.days.from_now do
      assert_emails 1 do
        post resend_account_dashboard_member_path(@account, member)
      end
      member.reload
      assert_not_equal old_token, member.invitation_token
    end
  end
end
