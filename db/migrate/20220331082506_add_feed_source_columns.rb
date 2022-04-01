class AddFeedSourceColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :feed_url, :string
    add_column :accounts, :feed_fetched_at, :datetime
    add_column :accounts, :feed_mark_canonical, :boolean, default: false

    add_column :posts, :canonical_url, :string
    add_column :posts, :feed_source_id, :string
    add_column :posts, :feed_source_url, :string
    add_index :posts, :canonical_url, unique: true
    add_index :posts, :feed_source_id, unique: true
    add_index :posts, :feed_source_url, unique: true
  end
end
