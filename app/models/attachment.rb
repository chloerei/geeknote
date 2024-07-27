class Attachment < ApplicationRecord
  belongs_to :account, optional: true
  belongs_to :user, optional: true
  has_one_attached :file
  has_secure_token :key

  validates :file, attached: true, size: { less_than: 10.megabytes }, content_type: [ :png, :gif, :jpg, :jpeg, :svg, :log, :md, :docx, :pptx, :xlsx, :txt, :patch, :pdf, :zip, :gz, :tgz, :mp4, :mov, :webm ]
end
