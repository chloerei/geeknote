class PostRevision < ApplicationRecord
  belongs_to :post
  belongs_to :user

  enum status: {
    autosaved: 0,
    published: 1
  }
end
