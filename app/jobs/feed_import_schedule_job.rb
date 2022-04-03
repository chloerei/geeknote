class FeedImportScheduleJob < ApplicationJob
  queue_as :default

  def perform
    Account.where.not(feed_url: nil).find_each do |account|
      FeedImportJob.perform_later(account)
    end
  end
end
