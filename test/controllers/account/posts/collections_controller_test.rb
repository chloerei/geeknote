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

  test "should get post collection by org admin" do
    organization = create(:organization)
    post = create(:post, account: organization.account)
    collection = create(:collection, account: organization.account)

    sign_in create(:user)
    get account_post_collections_path(post.account, post, account: organization.account.name)
    assert_response :not_found

    sign_in create(:membership, organization: organization).user
    get account_post_collections_path(post.account, post, account: organization.account.name)
    assert_response :not_found

    sign_in create(:membership, organization: organization, role: 'admin').user
    get account_post_collections_path(post.account, post, account: organization.account.name)
    assert_response :success
  end

  test "should add post collection by org admin" do
    organization = create(:organization)
    post = create(:post, account: organization.account)
    collection = create(:collection, account: organization.account)

    sign_in create(:user)
    assert_no_difference "collection.collection_items.count" do
      patch account_post_collection_path(post.account, post, collection, account: organization.account.name), params: { collection: { added: '1' } }, as: :turbo_stream
      assert_response :not_found
    end

    sign_in create(:membership, organization: organization).user
    assert_no_difference "collection.collection_items.count" do
      patch account_post_collection_path(post.account, post, collection, account: organization.account.name), params: { collection: { added: '1' } }, as: :turbo_stream
      assert_response :not_found
    end

    sign_in create(:membership, organization: organization, role: 'admin').user
    assert_difference "collection.collection_items.count" do
      patch account_post_collection_path(post.account, post, collection, account: organization.account.name), params: { collection: { added: '1' } }, as: :turbo_stream
      assert_response :success
    end

    assert_difference "collection.collection_items.count", -1 do
      patch account_post_collection_path(post.account, post, collection, account: organization.account.name), params: { collection: { added: '0' } }, as: :turbo_stream
      assert_response :success
    end
  end
end
