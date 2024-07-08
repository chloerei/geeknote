require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "should merge tags" do
    tag_1 = create(:tag)
    tag_2 = create(:tag)
    tag_3 = create(:tag)

    create(:post, tags: [ tag_1 ])
    create(:post, tags: [ tag_2 ])
    create(:post, tags: [ tag_3 ])

    assert_equal 1, tag_1.taggings.count
    assert_equal 1, tag_2.taggings.count
    assert_equal 1, tag_3.taggings.count

    tag_1.merge([ tag_2.name, tag_3.name ].join(","))

    assert_equal 3, tag_1.taggings.count
    assert_equal 0, tag_2.taggings.count
    assert_equal 0, tag_3.taggings.count

    # counter
    assert_equal 3, tag_1.reload.taggings_count

    # deleted
    assert_not Tag.find_by id: tag_2.id
    assert_not Tag.find_by id: tag_3.id
  end

  test "should not merge duplicate" do
    tag_1 = create(:tag)
    tag_2 = create(:tag)

    create(:post, tags: [ tag_1, tag_2 ])

    tag_1.merge(tag_2.name)

    assert_equal 1, tag_1.taggings.count
    assert_equal 0, tag_2.taggings.count
  end

  test "should not merge self" do
    tag = create(:tag)
    create(:post, tags: [ tag ])

    tag.merge(tag.name)

    assert_equal 1, tag.taggings.count
    assert Tag.find_by id: tag.id
  end
end
