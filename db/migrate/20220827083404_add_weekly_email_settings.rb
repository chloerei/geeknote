class AddWeeklyEmailSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :weekly_summary_email_enabled, :boolean, default: true, null: false

    add_column :sites, :weekly_summary_email_enabled, :boolean, default: true, null: false
    add_column :sites, :weekly_summary_header_html, :text
    add_column :sites, :weekly_summary_footer_html, :text
  end
end
