class RemoveFeedSourceColumns < ActiveRecord::Migration[8.0]
  def change
    remove_column :accounts, :feed_url, :string
    remove_column :accounts, :feed_fetched_at, :datetime
    remove_column :accounts, :feed_mark_canonical, :boolean, default: false

    remove_index :posts, [ :feed_source_id, :account_id ], where: "feed_source_id IS NOT NULL", unique: true
    remove_column :posts, :feed_source_id, :string
  end
end
