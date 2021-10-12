class AddEmailNotificationSettingsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :email_notification_enabled, :boolean, default: true, null: false
    add_column :users, :email_notification_comment_enabled, :boolean, default: true, null: false
  end
end
