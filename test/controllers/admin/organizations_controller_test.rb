require "test_helper"

class Admin::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, email: User::ADMIN_EMAILS.last)
    @organization = create(:organization)
    sign_in @admin
  end

  test "should get index" do
    get admin_organizations_path
    assert_response :success
  end

  test "should get post" do
    get admin_organization_path(@organization)
    assert_response :success
  end

  test "should edit post" do
    get edit_admin_organization_path(@organization)
    assert_response :success
  end

  test "should update post" do
    patch admin_organization_path(@organization), params: { organization: { name: 'changed' } }
    assert_redirected_to admin_organization_path(@organization)
    @organization.reload
    assert_equal 'changed', @organization.name
  end
end
