class AddUserIdToPosts < ActiveRecord::Migration[7.0]
  class Post < ApplicationRecord
    has_many :authors
    belongs_to :user
  end

  class Author < ApplicationRecord
    belongs_to :post
    belongs_to :user
  end

  class User < ApplicationRecord
    has_many :authors
  end

  def change
    add_belongs_to :posts, :user

    Post.find_each do |post|
      post.user = post.authors.first&.user
      post.save
    end
  end
end
