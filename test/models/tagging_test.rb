require "test_helper"

class TaggingTest < ActiveSupport::TestCase
  test "tag_list treats names differing only in case as one tag" do
    post = create(:post)

    # Tag names are citext, so both entries resolve to the same tag and the
    # tagging insert would violate its uniqueness index without deduping.
    post.tag_list = "Rails,rails"
    post.save!

    assert_equal [ "Rails" ], post.tags.pluck(:name)
    assert_equal 1, post.taggings.count
  end

  test "tag_list keeps distinct names" do
    post = create(:post)

    post.tag_list = "Ruby, Rails"
    post.save!

    assert_equal %w[Rails Ruby], post.tags.order(:name).pluck(:name)
  end
end
