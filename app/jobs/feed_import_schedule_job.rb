class FeedImportScheduleJob < ApplicationJob
  queue_as :default

  def perform
    Account.where.not(feed_url: nil).where("feed_fetched_at IS NULL OR feed_fetched_at < ?", 4.hours.ago).find_each do |account|
      FeedImportJob.perform_later(account)
    end
  end
end
