class PostRevision < ApplicationRecord
  belongs_to :post
  belongs_to :user

  enum status: {
    draft: 0,
    published: 1
  }
end
