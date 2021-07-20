class AddRestrictedToPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :restricted, :boolean, default: false
  end
end
