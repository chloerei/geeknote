class CreateFollows < ActiveRecord::Migration[6.1]
  def change
    create_table :follows do |t|
      t.belongs_to :user
      t.belongs_to :account, index: false

      t.timestamps

      t.index [ :account_id, :user_id ], unique: true
    end

    add_column :users, :followings_count, :integer, default: 0
    add_column :accounts, :followers_count, :integer, default: 0
  end
end
