require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new page" do
    user = create(:user)

    sign_in user
    get new_organization_path
    assert_response :success
  end

  test "should create organization" do
    user = create(:user)

    sign_in user
    assert_difference "Organization.count" do
      post organizations_path, params: { organization: { account_attributes: { name: "neworg" }, name: "org" } }
    end
    member = user.members.last
    assert member.admin?
  end
end
