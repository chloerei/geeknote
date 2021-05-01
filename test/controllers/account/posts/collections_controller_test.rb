require "test_helper"

class Account::Posts::CollectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get post collection by user" do
    user = create(:user)
    post = create(:post, account: user.account)
    collection = create(:collection, account: user.account)

    sign_in user
    get account_post_collections_path(post.account, post), as: :turbo_stream
    assert_response :success
  end

  test "should add to collection by user" do
    user = create(:user)
    post = create(:post, account: user.account)
    collection = create(:collection, account: user.account)

    sign_in user
    assert_difference "collection.collection_items.count" do
      patch account_post_collection_path(post.account, post, collection), params: { collection: { added: '1' } }, as: :turbo_stream
    end

    assert_difference "collection.collection_items.count", -1 do
      patch account_post_collection_path(post.account, post, collection), params: { collection: { added: '0' } }, as: :turbo_stream
    end

    sign_in create(:user)
    assert_no_difference "collection.collection_items.count" do
      patch account_post_collection_path(post.account, post, collection), params: { collection: { added: '1' } }, as: :turbo_stream
    end
  end
end
