require "test_helper"

class PostTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "should set published at" do
    post = create(:post, status: :draft)
    assert_nil post.published_at
    post.published!
    assert_not_nil post.published_at
  end

  test "should restricted post" do
    post = create(:post, status: "published")
    post.restricted!
    assert post.restricted?
    assert post.draft?

    post.remove_restricted
    assert_not post.restricted?
  end

  test "should validate canonical_url is valid URL" do
    post = create(:post)
    post.update(canonical_url: "https://example.com")
    assert post.valid?

    post.update(canonical_url: "javascript:alert('https://example.com')")
    assert_not post.valid?
    assert post.errors.added?(:canonical_url, :invalid_url)
  end
end
