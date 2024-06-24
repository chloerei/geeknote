class RemoveAccountIdInCommentsAndNotifications < ActiveRecord::Migration[7.1]
  def change
    remove_column :comments, :account_id, :bigint
    remove_column :notifications, :account_id, :bigint
  end
end
