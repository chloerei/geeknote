require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get account_deleted" do
    get account_deleted_path
    assert_response :success
  end
end
