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

  test "set_position adds post to top when series add_new_at is top" do
    account = create(:user_account)
    series = create(:series, account: account, add_new_at: :top)

    create(:post, account: account, series: series, status: :published)
    create(:post, account: account, series: series, status: :published)
    top_post = create(:post, account: account, series: series, status: :published)

    assert_equal 1, top_post.position
  end

  test "set_position adds post to bottom when series add_new_at is bottom" do
    account = create(:user_account)
    series = create(:series, account: account, add_new_at: :bottom)

    create(:post, account: account, series: series, status: :published)
    create(:post, account: account, series: series, status: :published)
    bottom_post = create(:post, account: account, series: series, status: :published)

    assert_equal 3, bottom_post.position
  end

  test "set_position does not change position when series_id is unchanged" do
    account = create(:user_account)
    series = create(:series, account: account, add_new_at: :bottom)

    post = create(:post, account: account, series: series, status: :published)
    create(:post, account: account, series: series, status: :published)
    assert_equal 1, post.reload.position

    post.update(title: "Updated title")
    assert_equal 1, post.reload.position
  end

  test "creates a revision when title or content changes" do
    post = create(:post)
    editor = create(:user)

    Current.set(session: editor.sessions.create!) do
      post.update(title: "New title", content: "New content")
    end

    revision = post.revisions.last
    assert_equal "New title", revision.title
    assert_equal "New content", revision.content
    assert_equal editor, revision.user
  end

  test "creates a revision when a post is created with content" do
    post = create(:post)
    assert_equal 1, post.revisions.count
    assert_equal "Title", post.revisions.last.title
    assert_equal "Content", post.revisions.last.content
  end

  test "does not create an additional revision when only non-content fields change" do
    post = create(:post)
    post.update(status: :published)
    assert_equal 1, post.revisions.count
  end

  test "does not create an additional revision when title and content are unchanged" do
    post = create(:post)
    post.update(excerpt: "Updated excerpt")
    assert_equal 1, post.revisions.count
  end

  test "skips revision creation when skip_revision is set" do
    post = create(:post, skip_revision: true)
    post.update(title: "Changed")
    assert_equal 0, post.revisions.count
  end

  test "deleting a post deletes its revisions" do
    post = create(:post)
    post.update(title: "New title")
    assert_equal 2, post.revisions.count

    post.destroy
    assert_equal 0, PostRevision.where(post_id: post.id).count
  end
end
