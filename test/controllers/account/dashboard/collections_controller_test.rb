require "test_helper"

class Account::Dashboard::CollectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get collection index" do
    user = create(:user)

    sign_in user
    get account_dashboard_collections_path(user.account)
    assert_response :success
  end

  test "should check manage permission" do
    organization = create(:organization)
    member = create(:user)
    admin = create(:user)
    organization.members.create(user: member, role: 'member')
    organization.members.create(user: admin, role: 'admin')

    sign_in member
    get account_dashboard_collections_path(organization.account)
    assert_response :not_found

    sign_in admin
    get account_dashboard_collections_path(organization.account)
    assert_response :success
  end

  test "should get collection detail" do
    user = create(:user)
    collection = create(:collection, account: user.account)
    create(:collection_item, collection: collection)

    sign_in user
    get account_dashboard_collection_path(user.account, collection)
    assert_response :success
  end

  test "should edit collection" do
    user = create(:user)
    collection = create(:collection, account: user.account)

    sign_in user
    get edit_account_dashboard_collection_path(user.account, collection)
    assert_response :success
  end

  test "should update collection" do
    user = create(:user)
    collection = create(:collection, account: user.account)

    sign_in user
    patch account_dashboard_collection_path(user.account, collection), params: { collection: { name: 'changed' } }
    assert_redirected_to account_dashboard_collection_path(user.account, collection)
    collection.reload
    assert 'changed', collection.name
  end

  test "should delete collection" do
    user = create(:user)
    collection = create(:collection, account: user.account)

    sign_in user
    assert_difference "user.account.collections.count", -1 do
      delete account_dashboard_collection_path(user.account, collection)
    end
    assert_redirected_to account_dashboard_collections_path(user.account)
  end
end
