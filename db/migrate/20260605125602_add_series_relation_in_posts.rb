class AddSeriesRelationInPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :posts, :series
    add_column :posts, :position, :integer

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE posts
          SET position = subquery.new_position
          FROM (
            SELECT id, ROW_NUMBER() OVER (
              PARTITION BY account_id, series_id
              ORDER BY id
            ) AS new_position
            FROM posts
          ) AS subquery
          WHERE posts.id = subquery.id
        SQL
      end
    end

    change_column_null :posts, :position, false
    add_index :posts, [ :account_id, :series_id, :position ], unique: true
  end
end
