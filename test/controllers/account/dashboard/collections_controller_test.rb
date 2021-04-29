require "test_helper"

class Account::Dashboard::CollectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index by user" do
    user = create(:user)

    sign_in user
    get account_dashboard_collections_path(user.account)
    assert_response :success
  end

  test "should get index by org member" do
    organization = create(:organization)

    sign_in create(:membership, organization: organization).user
    get account_dashboard_collections_path(organization.account)
    assert_response :success
  end

  test "should get new page by user" do
    user = create(:user)

    sign_in user
    get new_account_dashboard_collection_path(user.account)
    assert_response :success
  end

  test "should get index by org admin" do
    organization = create(:organization)

    sign_in create(:membership, organization: organization).user
    get new_account_dashboard_collection_path(organization.account)
    assert_response :not_found

    sign_in create(:membership, organization: organization, role: 'admin').user
    get new_account_dashboard_collection_path(organization.account)
    assert_response :success
  end

  test "should create collection by user" do
    user = create(:user)

    sign_in user
    post account_dashboard_collections_path(user.account), params: { collection: { name: 'name' }}
    assert_redirected_to account_dashboard_collection_path(user.account, user.account.collections.last)
  end

  test "should create collection by org admin" do
    organization = create(:organization)

    sign_in create(:membership, organization: organization).user
    post account_dashboard_collections_path(organization.account), params: { collection: { name: 'name' }}
    assert_response :not_found

    sign_in create(:membership, organization: organization, role: 'admin').user
    post account_dashboard_collections_path(organization.account), params: { collection: { name: 'name' }}
    assert_redirected_to account_dashboard_collection_path(organization.account, organization.account.collections.last)
  end

  test "should get show page by user" do
    user = create(:user)
    collection = create(:collection, account: user.account)

    sign_in user
    get account_dashboard_collection_path(user.account, collection)
    assert_response :success
  end

  test "should get show page by org member" do
    organization = create(:organization)
    collection = create(:collection, account: organization.account)

    sign_in create(:membership, organization: organization).user
    get account_dashboard_collection_path(organization.account, collection)
    assert_response :success
  end

  test "should get edit page by user" do
    user = create(:user)
    collection = create(:collection, account: user.account)

    sign_in user
    get edit_account_dashboard_collection_path(user.account, collection)
    assert_response :success
  end

  test "should get edit page by org admin" do
    organization = create(:organization)
    collection = create(:collection, account: organization.account)

    sign_in create(:membership, organization: organization).user
    get edit_account_dashboard_collection_path(organization.account, collection)
    assert_response :not_found

    sign_in create(:membership, organization: organization, role: 'admin').user
    get edit_account_dashboard_collection_path(organization.account, collection)
    assert_response :success
  end

  test "should update by user" do
    user = create(:user)
    collection = create(:collection, account: user.account)

    sign_in user
    patch account_dashboard_collection_path(user.account, collection), params: { collection: { name: 'change' }}
    assert_redirected_to account_dashboard_collection_path(user.account, collection)
  end

  test "should update by org admin" do
    organization = create(:organization)
    collection = create(:collection, account: organization.account)

    sign_in create(:membership, organization: organization).user
    patch account_dashboard_collection_path(organization.account, collection), params: { collection: { name: 'change' } }
    assert_response :not_found

    sign_in create(:membership, organization: organization, role: 'admin').user
    patch account_dashboard_collection_path(organization.account, collection), params: { collection: { name: 'change' } }
    assert_redirected_to account_dashboard_collection_path(organization.account, collection)
  end

  test "should destroy by user" do
    user = create(:user)
    collection = create(:collection, account: user.account)

    sign_in user
    delete account_dashboard_collection_path(user.account, collection)
    assert_redirected_to account_dashboard_collections_path(user.account)
  end

  test "should destroy by org admin" do
    organization = create(:organization)
    collection = create(:collection, account: organization.account)

    sign_in create(:membership, organization: organization).user
    delete account_dashboard_collection_path(organization.account, collection)
    assert_response :not_found

    sign_in create(:membership, organization: organization, role: 'admin').user
    delete account_dashboard_collection_path(organization.account, collection)
    assert_redirected_to account_dashboard_collections_path(organization.account)
  end

end
