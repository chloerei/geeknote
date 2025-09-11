class RemoveTrashedStatusInPosts < ActiveRecord::Migration[8.0]
  def change
    Post.where(status: 2).update_all(status: 0)
  end
end
