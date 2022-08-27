class WeeklySummaryScheduleJob < ApplicationJob
  queue_as :default

  def perform
    site = Site.first_or_create

    return unless site.weekly_summary_email_enabled?

    if Post.published.where(published_at: [Date.today - 7 .. Date.today]).count > 0
      User.where.not(email_verified_at: nil).where(email_notification_enabled: true, weekly_summary_email_enabled: true).find_each do |user|
        UserMailer.with(user: user).weekly_summary.deliver_later
      end
    end
  end
end
