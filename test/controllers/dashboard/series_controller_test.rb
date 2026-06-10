require "test_helper"

class Dashboard::SeriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index in personal" do
    user = create(:user)
    create(:series, account: user.account)
    create(:series)
    sign_in user

    get dashboard_series_index_url(user.account.name)
    assert_response :success
  end

  test "should get index in org as admin" do
    user = create(:user)
    organization = create(:organization)
    create(:member, user: user, organization: organization, role: "admin")
    sign_in user

    create(:series, account: organization.account)
    create(:series, account: organization.account)

    get dashboard_series_index_url(organization.account.name)
    assert_response :success
  end

  test "should get index in org as member" do
    user = create(:user)
    organization = create(:organization)
    create(:member, user: user, organization: organization, role: "member")
    sign_in user

    create(:series, account: organization.account)
    create(:series, account: organization.account)

    get dashboard_series_index_url(organization.account.name)
    assert_response :success
  end

  test "should show series in personal" do
    user = create(:user)
    series = create(:series, account: user.account)
    sign_in user

    get dashboard_series_url(user.account.name, series)
    assert_response :success
  end

  test "should show series in org as admin" do
    user = create(:user)
    organization = create(:organization)
    create(:member, user: user, organization: organization, role: "admin")
    series = create(:series, account: organization.account)
    sign_in user

    get dashboard_series_url(organization.account.name, series)
    assert_response :success
  end

  test "should show series in org as member" do
    user = create(:user)
    organization = create(:organization)
    create(:member, user: user, organization: organization, role: "member")
    series = create(:series, account: organization.account)
    sign_in user

    get dashboard_series_url(organization.account.name, series)
    assert_response :success
  end

  test "should get new" do
    user = create(:user)
    sign_in user

    get new_dashboard_series_url(user.account.name)
    assert_response :success
  end

  test "should create series" do
    user = create(:user)
    sign_in user

    assert_difference -> { user.account.series.count } do
      post dashboard_series_index_url(user.account.name), params: {
        series: { title: "New Series", description: "Description" }
      }
    end

    assert_redirected_to dashboard_series_index_path(user.account.name)
  end

  test "should not create series with invalid params" do
    user = create(:user)
    sign_in user

    assert_no_difference -> { user.account.series.count } do
      post dashboard_series_index_url(user.account.name), params: {
        series: { title: "" }
      }
    end

    assert_response :unprocessable_content
  end

  test "should get edit as personal" do
    user = create(:user)
    series = create(:series, account: user.account)
    sign_in user

    get edit_dashboard_series_url(user.account.name, series)
    assert_response :success
  end

  test "should not get edit for other series as personal" do
    user = create(:user)
    series = create(:series)
    sign_in user

    get edit_dashboard_series_url(user.account.name, series)
    assert_response :not_found
  end

  test "should get edit as admin" do
    user = create(:user)
    organization = create(:organization)
    create(:member, user: user, organization: organization, role: "admin")
    series = create(:series, account: organization.account)
    sign_in user

    get edit_dashboard_series_url(organization.account.name, series)
    assert_response :success
  end

  test "should get edit as member" do
    user = create(:user)
    organization = create(:organization)
    create(:member, user: user, organization: organization, role: "member")
    series = create(:series, account: organization.account)
    sign_in user

    get edit_dashboard_series_url(organization.account.name, series)
    assert_response :success
  end

  test "should update series" do
    user = create(:user)
    series = create(:series, account: user.account)
    sign_in user

    patch dashboard_series_url(user.account.name, series), params: {
      series: { title: "Updated Title" }
    }
    assert_redirected_to dashboard_series_index_path(user.account.name)
    assert_equal "Updated Title", series.reload.title
  end

  test "should not update series with invalid params" do
    user = create(:user)
    series = create(:series, account: user.account)
    sign_in user

    patch dashboard_series_url(user.account.name, series), params: {
      series: { title: "" }
    }
    assert_response :unprocessable_content
    assert_not_equal "", series.reload.title
  end

  test "should destroy series" do
    user = create(:user)
    series = create(:series, account: user.account)
    sign_in user

    assert_difference -> { user.account.series.count }, -1 do
      delete dashboard_series_url(user.account.name, series)
    end

    assert_redirected_to dashboard_series_index_path(user.account.name)
  end
end
