require "test_helper"

class Account::CollectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get collection index" do
    user = create(:user)
    collection = create(:collection, account: user.account)

    get account_collections_path(user.account)
    assert_response :success
  end

  test "should get public collection" do
    user = create(:user)
    collection = create(:collection, account: user.account, visibility: :public)

    get account_collection_path(user.account, collection)
    assert_response :success
  end

  test "should get private collection by user" do
    user = create(:user)
    collection = create(:collection, account: user.account, visibility: :private)

    get account_collection_path(user.account, collection)
    assert_response :not_found

    sign_in user
    get account_collection_path(user.account, collection)
    assert_response :success
  end

  test "should get private collection by org member" do
    organization = create(:organization)
    collection = create(:collection, account: organization.account)

    get account_collection_path(organization.account, collection)
    assert_response :not_found

    sign_in create(:membership, organization: organization).user
    get account_collection_path(organization.account, collection)
    assert_response :success
  end
end
