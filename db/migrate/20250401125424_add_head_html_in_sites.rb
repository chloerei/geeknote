class AddHeadHtmlInSites < ActiveRecord::Migration[8.0]
  def change
    add_column :sites, :global_head_html, :text

    rename_column :sites, :header_html, :site_header_html
    rename_column :sites, :footer_html, :site_footer_html
  end
end
