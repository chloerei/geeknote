require "test_helper"

class PostRevisionTest < ActiveSupport::TestCase
  test "belongs to post" do
    revision = create(:post_revision)
    assert revision.post.present?
  end

  test "user is optional" do
    revision = create(:post_revision, user: nil)
    assert_nil revision.user
  end
end
