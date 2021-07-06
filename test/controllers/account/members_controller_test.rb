require "test_helper"

class Account::MembersControllerTest < ActionDispatch::IntegrationTest
  test "should view org account members" do
    organization = create(:organization)
    create(:member, organization: organization)

    get account_members_path(organization.account)
    assert_response :success
  end

  test "should only show active members" do
    organization = create(:organization)
    create(:member, organization: organization, status: 'active')
    create(:member, organization: organization, status: 'pending')

    get account_members_path(organization.account)
    assert_response :success
    assert_select '.list__item', 1
  end
end
