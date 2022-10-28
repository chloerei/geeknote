require "test_helper"

class Account::Posts::SocialImagesControllerTest < ActionDispatch::IntegrationTest
  test "should get html response" do
    post = create(:post)

    get account_post_social_image_path(post.account, post)
    assert_response :success
  end
end
