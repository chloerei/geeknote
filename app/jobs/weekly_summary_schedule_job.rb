class WeeklySummaryScheduleJob < ApplicationJob
  queue_as :default

  def perform
    site = Site.first_or_create

    return unless site.weekly_digest_email_enabled?

    if Post.published.where(published_at: [Date.today - 7 .. Date.today]).where("likes_count > 0").count > 0
      User.where.not(email_verified_at: nil).where(email_notification_enabled: true, weekly_digest_email_enabled: true).find_each do |user|
        UserMailer.with(user: user).weekly_digest.deliver_later(queue: :low)
      end
    end
  end
end
