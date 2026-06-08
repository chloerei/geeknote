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
    post.restrict!
    assert post.restricted?
    assert post.draft?

    post.unrestrict!
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

  test "series_account_match is valid when series belongs to the same account" do
    account = create(:user_account)
    series = create(:series, account: account)
    post = build(:post, account: account, series: series)
    post.valid?
    assert_not post.errors.added?(:series, :account_mismatch)
  end

  test "series_account_match is invalid when series belongs to a different account" do
    series = create(:series)
    post = build(:post, series: series)
    post.valid?
    assert post.errors.added?(:series, :account_mismatch)
  end

  test "series_account_match is valid when series is nil" do
    post = build(:post, series: nil)
    post.valid?
    assert_not post.errors.added?(:series, :account_mismatch)
  end
end
