class PostRevision < ApplicationRecord
  belongs_to :post
  belongs_to :user

  enum :status, {
    draft: 0,
    published: 1
  }

  def prev
    post.revisions.order(id: :desc).where("id < ?", id).first
  end

  def display_name
    name || I18n.l(created_at, format: :short)
  end
end
