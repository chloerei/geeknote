require "test_helper"

class Account::TagsControllerTest < ActionDispatch::IntegrationTest
  test "should get tags index" do
    @account = create(:user_account)
    create(:post, account: @account, tag_list: %w(Ruby))

    get account_tags_path(@account)
    assert_response :success
  end

  test "should get tag show page" do
    @account = create(:user_account)
    create(:post, account: @account, tag_list: %w(Ruby))

    get account_tag_path(@account, id: 'Ruby')
    assert_response :success
  end
end
