namespace :data do
  desc "Migrate bookmarks to collections"
  task migrate_bookmarks: :environment do
    User.all.each do |user|
      if user.bookmarks.any?
        collection = user.account.collections.create(name: I18n.t('common.bookmarks'), visibility: 'private')

        user.bookmarks.includes(:post).each do |bookmark|
          collection.collection_items.create(post: bookmark.post, created_at: bookmark.created_at)
        end
      end
    end
  end
end
