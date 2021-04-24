require "test_helper"

class Account::Dashboard::MembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = create(:organization)
  end

  test "member can visit membership dashboard" do
    sign_in create(:user)
    get account_dashboard_memberships_path(@organization.account)
    assert_response :not_found

    sign_in create(:membership, organization: @organization, role: 'member').user
    get account_dashboard_memberships_path(@organization.account)
    assert_response :success
  end

  test "admin can create membership" do
    sign_in create(:user)
    post account_dashboard_memberships_path(@organization.account), params: { membership: { identifier: 'account@example.com' } }
    assert_response :not_found

    sign_in create(:membership, organization: @organization, role: 'member').user
    post account_dashboard_memberships_path(@organization.account), params: { membership: { identifier: 'account@example.com' } }
    assert_response :not_found

    sign_in create(:membership, organization: @organization, role: 'admin').user
    assert_difference "@organization.memberships.count" do
      post account_dashboard_memberships_path(@organization.account), params: { membership: { identifier: 'account@example.com', role: 'admin' } }
    end
    assert_redirected_to account_dashboard_membership_path(@organization.account, @organization.memberships.last)
    assert_equal 'member', @organization.memberships.last.role
    assert_equal current_user, @organization.memberships.last.inviter

    sign_in create(:membership, organization: @organization, role: 'owner').user
    assert_difference "@organization.memberships.count" do
      post account_dashboard_memberships_path(@organization.account), params: { membership: { identifier: 'admin@example.com', role: 'admin' } }
    end
    assert_redirected_to account_dashboard_membership_path(@organization.account, @organization.memberships.last)
    assert_equal 'admin', @organization.memberships.last.role
  end

  test "member can visit membership detail" do
    membership = create(:membership, organization: @organization)

    sign_in create(:user)
    get account_dashboard_membership_path(@organization.account, membership)
    assert_response :not_found

    sign_in create(:membership, organization: @organization, role: 'member').user
    get account_dashboard_membership_path(@organization.account, membership)
    assert_response :success
  end

  test "admin can edit membership" do
    membership = create(:membership, organization: @organization)

    sign_in create(:user)
    get edit_account_dashboard_membership_path(@organization.account, membership)
    assert_response :not_found

    sign_in create(:membership, organization: @organization, role: 'member').user
    get edit_account_dashboard_membership_path(@organization.account, membership)
    assert_response :not_found

    sign_in create(:membership, organization: @organization, role: 'admin').user
    get edit_account_dashboard_membership_path(@organization.account, membership)
    assert_response :success
  end

  test "owner can update membership role" do
    membership = create(:membership, organization: @organization)

    sign_in create(:user)
    patch account_dashboard_membership_path(@organization.account, membership), params: { membership: { role: 'admin' }}
    assert_response :not_found

    sign_in create(:membership, organization: @organization, role: 'member').user
    patch account_dashboard_membership_path(@organization.account, membership), params: { membership: { role: 'admin' }}
    assert_response :not_found

    sign_in create(:membership, organization: @organization, role: 'admin').user
    patch account_dashboard_membership_path(@organization.account, membership), params: { membership: { role: 'admin' }}
    assert_redirected_to account_dashboard_membership_path(@organization.account, membership)
    membership.reload
    assert membership.member?

    sign_in create(:membership, organization: @organization, role: 'owner').user
    patch account_dashboard_membership_path(@organization.account, membership), params: { membership: { role: 'admin' }}
    assert_redirected_to account_dashboard_membership_path(@organization.account, membership)
    membership.reload
    assert membership.admin?
  end

  test "admin can remove member" do
    membership = create(:membership, organization: @organization)

    sign_in create(:user)
    delete account_dashboard_membership_path(@organization.account, membership)
    assert_response :not_found

    sign_in create(:membership, organization: @organization, role: 'member').user
    delete account_dashboard_membership_path(@organization.account, membership)
    assert_response :not_found

    sign_in create(:membership, organization: @organization, role: 'admin').user
    assert_difference "@organization.memberships.count", -1 do
      delete account_dashboard_membership_path(@organization.account, membership)
    end
    assert_redirected_to account_dashboard_memberships_path(@organization.account)
  end

  test "owner can remove admin" do
    membership = create(:membership, organization: @organization, role: 'admin')

    sign_in create(:membership, organization: @organization, role: 'admin').user
    assert_no_difference "@organization.memberships.count" do
      delete account_dashboard_membership_path(@organization.account, membership)
    end
    assert_redirected_to account_dashboard_memberships_path(@organization.account)

    sign_in create(:membership, organization: @organization, role: 'owner').user
    assert_difference "@organization.memberships.count", -1 do
      delete account_dashboard_membership_path(@organization.account, membership)
    end
    assert_redirected_to account_dashboard_memberships_path(@organization.account)
  end
end
