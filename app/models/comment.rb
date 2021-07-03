class Comment < ApplicationRecord
  include Likable

  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :parent, class_name: 'Comment', optional: true, counter_cache: :replies_count
  belongs_to :account
  belongs_to :user
  has_many :replies, class_name: 'Comment', foreign_key: :parent_id
  has_many :notifications, as: :record, dependent: :destroy

  validates :content, presence: true
  validate :check_parent_comment

  scope :no_parent, -> { where(parent_id: nil) }

  def check_parent_comment
    if parent && parent.commentable != commentable
      errors.add(:parent, :invalid)
    end
  end

  def ancestors
    sql = <<~EOF
      with recursive ancestors as (
        select comments.* from comments where id = :parent_id
        union all
        select comments.* from comments join ancestors on ancestors.parent_id = comments.id
      ) select * from ancestors
    EOF
    Comment.find_by_sql([sql, { parent_id: parent_id }])
  end
end
