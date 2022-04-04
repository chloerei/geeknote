class AddFeedSourceColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :feed_url, :string
    add_column :accounts, :feed_fetched_at, :datetime
    add_column :accounts, :feed_mark_canonical, :boolean, default: false

    add_column :posts, :canonical_url, :string
    add_column :posts, :feed_source_id, :string
    add_index :posts, [:feed_source_id, :account_id], where: "feed_source_id IS NOT NULL", unique: true
  end
end
