class CreateTags < ActiveRecord::Migration[6.1]
  def change
    create_table :tags do |t|
      t.citext :name
      t.integer :taggings_count, default: 0

      t.timestamps

      t.index :name, unique: true
    end
  end
end
