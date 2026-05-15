require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "should get new page" do
    sign_in @user
    get new_organization_path
    assert_response :success
  end

  test "should create organization" do
    sign_in @user
    assert_difference "Organization.count" do
      post organizations_path, params: { organization: { account_attributes: { name: "neworg" }, name: "org" } }
    end
    member = @user.members.last
    assert member.admin?
  end

  test "should get index with no organizations" do
    sign_in @user
    get organizations_url
    assert_response :success
  end

  test "should list organizations where user is admin" do
    organization = create(:organization, name: "AdminOrg")
    create(:member, organization: organization, user: @user, role: :admin)

    sign_in @user
    get organizations_url
    assert_response :success
    assert_select "a[href='#{dashboard_root_path(organization.account.name)}']"
  end

  test "should list organizations where user is ordinary member" do
    organization = create(:organization, name: "MemberOrg")
    create(:member, organization: organization, user: @user, role: :member, status: :active)

    sign_in @user
    get organizations_url
    assert_response :success
    assert_select "a[href='#{dashboard_root_path(organization.account.name)}']"
  end

  test "list count matches user organizations count" do
    orgs = create_list(:organization, 3)
    orgs.each { |org| create(:member, organization: org, user: @user, role: :member, status: :active) }

    sign_in @user
    get organizations_url
    assert_response :success

    orgs.each do |org|
      assert_select "a[href='#{dashboard_root_path(org.account.name)}']"
    end
  end

  test "should not list unrelated organizations" do
    my_org = create(:organization, name: "MyOrg")
    create(:member, organization: my_org, user: @user, role: :admin)

    other_user = create(:user)
    other_org = create(:organization, name: "OtherOrg")
    create(:member, organization: other_org, user: other_user, role: :admin)

    sign_in @user
    get organizations_url
    assert_response :success
    assert_select "a[href='#{dashboard_root_path(my_org.account.name)}']"
    assert_select "a[href='#{dashboard_root_path(other_org.account.name)}']", count: 0
  end

  test "should require authentication" do
    get organizations_url
    assert_redirected_to new_session_url
  end
end
