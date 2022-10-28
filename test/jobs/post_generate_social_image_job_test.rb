require "test_helper"

class PostGenerateSocialImageJobTest < ActiveJob::TestCase
  test "should generate image" do
    post = create(:post)
    PostGenerateSocialImageJob.perform_now(post)
    assert post.social_image.attached?
  end
end
