class AddEmailNotificationSettingsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :email_notification_enabled, :boolean, default: true, null: false
    add_column :users, :comment_email_notification_enabled, :boolean, default: true, null: false
  end
end
