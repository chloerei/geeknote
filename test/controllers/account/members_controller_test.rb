require "test_helper"

class Account::MembersControllerTest < ActionDispatch::IntegrationTest
  test "should view org account members" do
    organization = create(:organization)

    get account_root_path(organization.account)
    assert_response :success
  end
end
