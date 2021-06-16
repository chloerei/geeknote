class AddPostSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :allow_comments, :boolean, default: true
    add_column :posts, :featured, :boolean, default: false
  end
end
