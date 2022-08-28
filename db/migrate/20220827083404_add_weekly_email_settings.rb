class AddWeeklyEmailSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :weekly_digest_email_enabled, :boolean, default: true, null: false

    add_column :sites, :weekly_digest_email_enabled, :boolean, default: true, null: false
    add_column :sites, :weekly_digest_header_html, :text
    add_column :sites, :weekly_digest_footer_html, :text
  end
end
