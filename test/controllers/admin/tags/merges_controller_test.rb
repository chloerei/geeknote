require "test_helper"

class Admin::Tags::MergesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, email: User::ADMIN_EMAILS.last)
    sign_in @admin
  end

  test "should get new page" do
    tag = create(:tag)

    get new_admin_tag_merge_path(tag)
    assert_response :success
  end

  test "should create merge" do
    tag_1 = create(:tag)
    tag_2 = create(:tag)

    post_1 = create(:post, tags: [ tag_1 ])
    post_2 = create(:post, tags: [ tag_2 ])

    post admin_tag_merge_path(tag_1), params: { tag_list: tag_2.name }
    assert_redirected_to admin_tag_path(tag_1)

    assert_equal [ tag_1 ], post_1.reload.tags
    assert_equal [ tag_1 ], post_2.reload.tags
  end
end
