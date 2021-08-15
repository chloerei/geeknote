require "test_helper"

class Account::Dashboard::Collections::CollectionItemsControllerTest < ActionDispatch::IntegrationTest
  test "should update position" do
    user = create(:user)
    collection = create(:collection, account: user.account, add_to: 'bottom')
    collection_item_1 = create(:collection_item, collection: collection)
    collection_item_2 = create(:collection_item, collection: collection)

    sign_in user
    patch account_dashboard_collection_collection_item_path(user.account, collection, collection_item_1), params: { collection_item: { position: 1 } }
    assert_equal 1, collection_item_1.reload.position
    assert_equal 0, collection_item_2.reload.position
  end

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
