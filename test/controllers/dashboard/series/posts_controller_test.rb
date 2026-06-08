require "test_helper"

class Dashboard::Series::PostsControllerTest < ActionDispatch::IntegrationTest
  test "should not update post position in series for non-owner in personal account" do
    user = create(:user)
    other_user = create(:user)
    series = create(:series, account: user.account)
    post = create(:post, account: user.account, series: series, user: user)

    sign_in other_user

    patch dashboard_series_post_path(user.account.name, series, post), params: {
      post: { position: 2 }
    }

    assert_redirected_to account_root_path(user.account.name)
  end

  test "should update post position in series in personal account" do
    user = create(:user)
    series = create(:series, account: user.account)
    post1 = create(:post, account: user.account, series: series, user: user, position: 1)
    post2 = create(:post, account: user.account, series: series, user: user, position: 2)
    post3 = create(:post, account: user.account, series: series, user: user, position: 3)

    sign_in user

    patch dashboard_series_post_path(user.account.name, series, post3), params: {
      post: { position: 1 }
    }

    assert_response :no_content

    # After moving post3 to position 1, the positioning gem auto-updates the others
    assert_equal 1, post3.reload.position
    assert_equal 2, post1.reload.position
    assert_equal 3, post2.reload.position
  end

  test "should not update post position for post not belonging to the series" do
    user = create(:user)
    series = create(:series, account: user.account)
    other_series = create(:series, account: user.account)
    other_post = create(:post, account: user.account, series: other_series, user: user)

    sign_in user

    patch dashboard_series_post_path(user.account.name, series, other_post), params: {
      post: { position: 2 }
    }

    assert_response :not_found
  end
end
