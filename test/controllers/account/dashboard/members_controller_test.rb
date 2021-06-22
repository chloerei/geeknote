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

    sign_in create(:member, organization: @organization, role: 'writer').user
    get account_dashboard_members_path(@account)
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'editor').user
    get account_dashboard_members_path(@account)
    assert_response :success
  end

  test "invite member" do
    sign_in create(:user)
    post account_dashboard_members_path(@account), params: { member: { identifier: 'account@example.com' } }
    assert_response :not_found

    # Writer
    sign_in create(:member, organization: @organization, role: 'writer').user
    post account_dashboard_members_path(@account), params: { member: { identifier: 'account@example.com' } }
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'editor').user

    # Editor
    assert_emails 1 do
      assert_difference "@organization.members.count" do
        post account_dashboard_members_path(@account), params: { member: { identifier: 'writer@example.com', role: 'writer' } }
      end
    end
    assert_redirected_to account_dashboard_member_path(@account, @organization.members.last)
    assert_equal 'writer', @organization.members.last.role
    assert_equal current_user, @organization.members.last.inviter
    assert_not_nil @organization.members.last.invited_at
    # editor can't invite editor
    assert_no_difference "@organization.members.count" do
      post account_dashboard_members_path(@account), params: { member: { identifier: 'editor@example.com', role: 'editor' } }
    end

    # Admin
    sign_in create(:member, organization: @organization, role: 'admin').user
    assert_difference "@organization.members.count" do
      post account_dashboard_members_path(@account), params: { member: { identifier: 'editor@example.com', role: 'editor' } }
    end
    assert_redirected_to account_dashboard_member_path(@account, @organization.members.last)
    assert_equal 'editor', @organization.members.last.role
    # Admin can't invite admin
    assert_no_difference "@organization.members.count" do
      post account_dashboard_members_path(@account), params: { member: { identifier: 'admin@example.com', role: 'admin' } }
    end

    # Owner
    sign_in create(:member, organization: @organization, role: 'owner').user
    assert_difference "@organization.members.count" do
      post account_dashboard_members_path(@account), params: { member: { identifier: 'admin@example.com', role: 'admin' } }
    end
    assert_redirected_to account_dashboard_member_path(@account, @organization.members.last)
    assert_equal 'admin', @organization.members.last.role
    # Owner invite Owner
    assert_difference "@organization.members.count" do
      post account_dashboard_members_path(@account), params: { member: { identifier: 'owner@example.com', role: 'owner' } }
    end
  end

  test "view member detail" do
    member = create(:member, organization: @organization)

    sign_in create(:user)
    get account_dashboard_member_path(@account, member)
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'writer').user
    get account_dashboard_member_path(@account, member)
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'editor').user
    get account_dashboard_member_path(@account, member)
    assert_response :success
  end

  test "admin can edit member" do
    member = create(:member, organization: @organization, role: 'writer')

    sign_in create(:user)
    get edit_account_dashboard_member_path(@account, member)
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'writer').user
    get edit_account_dashboard_member_path(@account, member)
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'editor').user
    get edit_account_dashboard_member_path(@account, member)
    assert_response :success
  end

  test "update member role" do
    member = create(:member, organization: @organization, role: 'contributor')

    sign_in create(:user)
    patch account_dashboard_member_path(@account, member), params: { member: { role: 'admin' }}
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'writer').user
    patch account_dashboard_member_path(@account, member), params: { member: { role: 'admin' }}
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'editor').user
    patch account_dashboard_member_path(@account, member), params: { member: { role: 'admin' }}
    member.reload
    assert member.contributor?

    sign_in create(:member, organization: @organization, role: 'admin').user
    patch account_dashboard_member_path(@account, member), params: { member: { role: 'writer' }}
    member.reload
    assert member.writer?
    patch account_dashboard_member_path(@account, member), params: { member: { role: 'editor' }}
    member.reload
    assert member.editor?

    sign_in create(:member, organization: @organization, role: 'owner').user
    patch account_dashboard_member_path(@account, member), params: { member: { role: 'admin' }}
    member.reload
    assert member.admin?
  end

  test "editor remove writer" do
    member = create(:member, organization: @organization, role: 'writer')

    sign_in create(:user)
    delete account_dashboard_member_path(@account, member)
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'writer').user
    delete account_dashboard_member_path(@account, member)
    assert_response :not_found

    sign_in create(:member, organization: @organization, role: 'editor').user
    assert_difference "@organization.members.count", -1 do
      delete account_dashboard_member_path(@account, member)
    end
    assert_redirected_to account_dashboard_members_path(@account)
  end

  test "owner can remove admin" do
    member = create(:member, organization: @organization, role: 'admin')

    sign_in create(:member, organization: @organization, role: 'admin').user
    assert_no_difference "@organization.members.count" do
      delete account_dashboard_member_path(@account, member)
    end
    assert_redirected_to account_dashboard_members_path(@account)

    sign_in create(:member, organization: @organization, role: 'owner').user
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
      assert member.invitation_exipred?
      assert_emails 1 do
        post resend_account_dashboard_member_path(@account, member)
      end
      member.reload
      assert_not member.invitation_exipred?
      assert_not_equal old_token, member.invitation_token
    end
  end
end
