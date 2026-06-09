require "test_helper"

class Account::SeriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "should get index" do
    create(:series, account: @user.account)

    get account_series_index_url(@user.account.name)
    assert_response :success
  end

  test "should get show" do
    series = create(:series, account: @user.account)
    create(:published_post, series: series, account: @user.account, user: @user)

    get account_series_url(@user.account.name, series)
    assert_response :success
  end
end
