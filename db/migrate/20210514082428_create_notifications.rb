class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.belongs_to :account
      t.belongs_to :user
      t.belongs_to :record, polymorphic: true
      t.integer :type
      t.datetime :read_at

      t.timestamps
    end
  end
end
