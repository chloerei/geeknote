require "test_helper"

class Account::Dashboard::Collections::CollectionItemsControllerTest < ActionDispatch::IntegrationTest
  test "should delete collection item" do
    user = create(:user)
    collection = create(:collection, account: user.account)
    collection_item = create(:collection_item, collection: collection)

    sign_in user
    assert_difference "collection.collection_items.count", -1 do
      delete account_dashboard_collection_collection_item_path(user.account, collection, collection_item)
    end
  end
end
