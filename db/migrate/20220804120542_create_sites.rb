class CreateSites < ActiveRecord::Migration[7.0]
  def change
    create_table :sites do |t|
      t.string :name
      t.string :description

      t.text :header_html
      t.text :footer_html
      t.text :sidebar_header_html
      t.text :sidebar_footer_html

      t.timestamps
    end
  end
end
