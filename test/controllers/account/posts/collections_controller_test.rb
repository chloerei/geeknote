require "test_helper"

class Account::Posts::CollectionsControllerTest < ActionDispatch::IntegrationTest
  test "should add post to collection" do
    user = create(:user)
    collection = create(:collection, account: user.account)
    post = create(:post)

    sign_in user
    get account_post_collections_path(post.account, post)
    assert_response :success

    assert_difference "collection.collection_items.count", 1 do
      patch account_post_collection_path(post.account, post, collection), params: { collection: { added: '1' }}, as: :turbo_stream
    end

    assert_difference "collection.collection_items.count", -1 do
      patch account_post_collection_path(post.account, post, collection), params: { collection: { added: '0' }}, as: :turbo_stream
    end
  end

  test "sholud create and add to collection" do
    user = create(:user)
    post = create(:post)

    sign_in user
    post account_post_collections_path(post.account, post), params: { collection: { name: 'test' }}
    assert_redirected_to account_post_collections_path(post.account, post)

    collection = user.account.collections.last
    assert collection.collection_items.where(post: post).exists?
  end

  test "should switch collection account" do
    user = create(:user)
    organization = create(:organization)
    collection = create(:collection, account: organization.account)
    post = create(:post)

    sign_in user
    assert_raise ActiveRecord::RecordNotFound do
      put switch_account_post_collections_path(post.account, post, account: organization.account.name)
    end

    organization.members.create(user: user, role: 'admin')
    put switch_account_post_collections_path(post.account, post, account: organization.account.name)
    assert_redirected_to account_post_collections_path(post.account, post)

    assert_difference "collection.collection_items.count", 1 do
      patch account_post_collection_path(post.account, post, collection), params: { collection: { added: '1' }}, as: :turbo_stream
    end
  end
end
