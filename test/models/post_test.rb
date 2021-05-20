require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "should set published at" do
    post = create(:post, status: :draft)
    assert_nil post.published_at
    post.published!
    assert_not_nil post.published_at
  end
end
