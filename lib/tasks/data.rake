namespace :data do
  desc "Generate post revision for exists post"
  task generate_post_revision: :environment do
    Post.find_each do |post|
      post.save_revision(
        status: post.published? ? "published" : "draft",
        user: post.user
      )
    end
  end

  desc "Migrate collection items to bookmarks"
  task migrate_collection_items_to_bookmarks: :environment do
    CollectionItem.find_each do |collection_item|
      if collection_item.collection.account.user?
        Bookmark.create(
          user: collection_item.collection.account.owner,
          post: collection_item.post,
          created_at: collection_item.created_at,
          updated_at: collection_item.updated_at
        )
      end
    end
  end
end
