class Export < ApplicationRecord
  enum status: {
    pending: 0,
    completed: 1
  }

  belongs_to :account
  has_one_attached :file

  after_create_commit :perform_export_later

  def perform_export_later
    AccountExportJob.perform_later(self)
  end
end
