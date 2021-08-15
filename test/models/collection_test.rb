require "test_helper"

class CollectionTest < ActiveSupport::TestCase
  test "should reorder when order_type change" do
    collection = create(:collection)
    collection_item_1 = create(:collection_item, collection: collection, created_at: 3.days.ago)
    collection_item_2 = create(:collection_item, collection: collection, created_at: 2.days.ago)
    collection_item_3 = create(:collection_item, collection: collection, created_at: 1.days.ago)

    assert_equal 2, collection_item_1.reload.position
    assert_equal 1, collection_item_2.reload.position
    assert_equal 0, collection_item_3.reload.position

    collection.order_type_added_asc!
    assert_equal 0, collection_item_1.reload.position
    assert_equal 1, collection_item_2.reload.position
    assert_equal 2, collection_item_3.reload.position
  end
end
