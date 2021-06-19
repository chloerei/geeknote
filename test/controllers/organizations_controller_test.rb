require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    user = create(:user)
    organization = create(:organization)
    create(:member, user: user, organization: organization)

    sign_in user
    get organizations_path
    assert_response :success
  end

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
      post organizations_path, params: { organization: { account_attributes: { name: 'neworg' }, name: 'org' }}
    end
    member = user.members.last
    assert member.owner?
  end
end
