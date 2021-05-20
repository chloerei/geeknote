class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.citext :name
      t.belongs_to :owner, polymorphic: true
      t.integer :followers_count, default: 0

      t.timestamps

      t.index :name, unique: true
    end
  end
end
