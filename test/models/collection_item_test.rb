require "test_helper"

class CollectionItemTest < ActiveSupport::TestCase
  test "should set position when create" do
    collection = create(:collection)

    # default add to top
    first_item = create(:collection_item, collection: collection)
    assert_equal 0, first_item.position
    second_item = create(:collection_item, collection: collection)
    assert_equal 0, second_item.position
    assert_equal 1, first_item.reload.position
  end

  test "should set position when create witn add to buttom" do
    collection = create(:collection, add_to: 'bottom')

    # default add to top
    first_item = create(:collection_item, collection: collection)
    assert_equal 0, first_item.position
    second_item = create(:collection_item, collection: collection)
    assert_equal 0, first_item.reload.position
    assert_equal 1, second_item.position
  end

  test "should reorder after items when destroy" do
    collection = create(:collection, add_to: 'bottom')

    first_item = create(:collection_item, collection: collection)
    second_item = create(:collection_item, collection: collection)
    third_item = create(:collection_item, collection: collection)

    second_item.destroy
    assert_equal 0, first_item.reload.position
    assert_equal 1, third_item.reload.position
  end

  test "should set position when order_type added_asc" do
    collection = create(:collection, order_type: 'added_asc')

    first_item = create(:collection_item, collection: collection)
    second_item = create(:collection_item, collection: collection)
    third_item = create(:collection_item, collection: collection)

    assert_equal 0, first_item.reload.position
    assert_equal 1, second_item.reload.position
    assert_equal 2, third_item.reload.position
  end

  test "should set position when order_type added_desc" do
    collection = create(:collection, order_type: 'added_desc')

    first_item = create(:collection_item, collection: collection)
    second_item = create(:collection_item, collection: collection)
    third_item = create(:collection_item, collection: collection)

    assert_equal 2, first_item.reload.position
    assert_equal 1, second_item.reload.position
    assert_equal 0, third_item.reload.position
  end

  test "should set position when order_type published_asc" do
    collection = create(:collection, order_type: 'published_asc')

    first_post = create(:post, published_at: 3.day.ago)
    second_post = create(:post, published_at: 1.day.ago)
    third_post = create(:post, published_at: 2.day.ago)

    first_item = create(:collection_item, collection: collection, post: first_post)
    second_item = create(:collection_item, collection: collection, post: second_post)
    third_item = create(:collection_item, collection: collection, post: third_post)

    assert_equal 0, first_item.reload.position
    assert_equal 2, second_item.reload.position
    assert_equal 1, third_item.reload.position
  end

  test "should set position when order_type published_desc" do
    collection = create(:collection, order_type: 'published_desc')

    first_post = create(:post, published_at: 3.day.ago)
    second_post = create(:post, published_at: 1.day.ago)
    third_post = create(:post, published_at: 2.day.ago)

    first_item = create(:collection_item, collection: collection, post: first_post)
    second_item = create(:collection_item, collection: collection, post: second_post)
    third_item = create(:collection_item, collection: collection, post: third_post)

    assert_equal 2, first_item.reload.position
    assert_equal 0, second_item.reload.position
    assert_equal 1, third_item.reload.position
  end

  test "should move item" do
    collection = create(:collection, add_to: 'bottom')

    first_item = create(:collection_item, collection: collection)
    second_item = create(:collection_item, collection: collection)
    third_item = create(:collection_item, collection: collection)

    assert_equal 0, first_item.reload.position
    assert_equal 1, second_item.reload.position
    assert_equal 2, third_item.reload.position

    second_item.move_to_bottom

    assert_equal 0, first_item.reload.position
    assert_equal 1, third_item.reload.position
    assert_equal 2, second_item.reload.position

    third_item.move_to_top

    assert_equal 0, third_item.reload.position
    assert_equal 1, first_item.reload.position
    assert_equal 2, second_item.reload.position

    first_item.move_to(0)

    assert_equal 0, first_item.reload.position
    assert_equal 1, third_item.reload.position
    assert_equal 2, second_item.reload.position

    third_item.move_to(2)
    assert_equal 0, first_item.reload.position
    assert_equal 1, second_item.reload.position
    assert_equal 2, third_item.reload.position
  end
end
