class CreateSeries < ActiveRecord::Migration[8.1]
  def change
    create_table :series do |t|
      t.belongs_to :account, null: false, foreign_key: true

      t.string :title
      t.text :description
      t.integer :add_new_at, null: false, default: 0

      t.timestamps
    end
  end
end
