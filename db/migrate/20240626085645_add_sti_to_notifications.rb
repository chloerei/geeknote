class AddStiToNotifications < ActiveRecord::Migration[7.1]
  def change
    # don't want to migrate old data
    Notification.delete_all

    remove_column :notifications, :type, :integer
    add_column :notifications, :type, :string

    remove_reference :notifications, :record, polymorphic: true
    add_column :notifications, :data, :jsonb, default: {}

    add_index :notifications, [ :user_id, :read_at ], where: "read_at IS NULL", name: "index_notifications_on_unread"
  end
end
