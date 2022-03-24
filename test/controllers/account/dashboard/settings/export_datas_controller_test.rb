require "test_helper"

class Account::Dashboard::Settings::ExportDatasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = create(:user_account)
    create(:post, account: @account)
  end

  test "should get exports index" do
    sign_in @account.owner
    get account_dashboard_settings_exports_path(@account)
    assert_response :success
  end

  test "should create export" do
    sign_in @account.owner
    assert_difference "@account.exports.count", 1 do
      post account_dashboard_settings_exports_path(@account)
    end

    # should not create if one pending
    assert_no_difference "@account.exports.count" do
      post account_dashboard_settings_exports_path(@account)
    end
  end

  test "should destroy export" do
    sign_in @account.owner
    export = @account.exports.create

    assert_difference "@account.exports.count", -1 do
      delete account_dashboard_settings_export_path(@account, export)
    end
  end
end
