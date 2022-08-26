class WeeklySummaryScheduleJob < ApplicationJob
  queue_as :default

  def perform
    if Post.published.where(published_at: [Date.today - 7 .. Date.today]).count > 0
      User.where.not(email_verified_at: nil).find_each do |user|
        UserMailer.with(user: user).weekly_summary.deliver_later
      end
    end
  end
end
