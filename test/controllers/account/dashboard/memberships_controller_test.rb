require "test_helper"

class Account::Dashboard::MembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = create(:organization)
    @user = create(:user)
    create(:membership, organization: @organization, user: user, role: :owner)
  end

  test "should create membership invitation" do
  end
end
