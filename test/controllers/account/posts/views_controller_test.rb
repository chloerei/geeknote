require "test_helper"

class Account::Posts::ViewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = create(:post)
  end

  test "should create view" do
    assert_difference "Ahoy::Event.count", 1 do
      assert_difference "@post.reload.views_count", 1 do
        post account_post_views_url(account_name: @post.account.name, post_id: @post.id)
        assert_response :success
      end
    end
  end
end
