class AddFeedSourceColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :feed_url, :string
    add_column :accounts, :feed_fetched_at, :datetime

    add_column :posts, :feed_source_url, :string
    add_index :posts, :feed_source_url
  end
end
