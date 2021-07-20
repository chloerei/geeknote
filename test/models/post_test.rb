require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "should set published at" do
    post = create(:post, status: :draft)
    assert_nil post.published_at
    post.published!
    assert_not_nil post.published_at
  end

  test "should restricted post" do
    post = create(:post, status: 'published')
    post.restricted!
    assert post.restricted?
    assert post.draft?

    post.remove_restricted
    assert_not post.restricted?
  end
end
