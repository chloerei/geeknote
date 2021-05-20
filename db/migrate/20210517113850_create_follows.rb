class CreateFollows < ActiveRecord::Migration[6.1]
  def change
    create_table :follows do |t|
      t.belongs_to :user
      t.belongs_to :account, index: false

      t.timestamps

      t.index [:account_id, :user_id], unique: true
    end
  end
end
