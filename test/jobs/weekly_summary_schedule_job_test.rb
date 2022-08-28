require "test_helper"

class WeeklySummaryScheduleJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "should not deliver if no user" do
    create(:post, status: :published, published_at: 1.day.ago)

    assert_no_enqueued_emails do
      WeeklySummaryScheduleJob.perform_now
    end
  end

  test "should not deliver if no post published in range" do
    create(:user, email_verified_at: Time.now)
    create(:post, status: :published, published_at: 8.day.ago)
    create(:post, status: :published, published_at: Time.now)

    assert_no_enqueued_emails do
      WeeklySummaryScheduleJob.perform_now
    end
  end

  test "should deliver summary" do
    user = create(:user, email_verified_at: Time.now)
    create(:post, status: :published, published_at: 1.day.ago)

    assert_enqueued_email_with UserMailer, :weekly_digest, args: { user: user } do
      WeeklySummaryScheduleJob.perform_now
    end
  end

  test "should not deliver if user disable notification" do
    user = create(:user, email_verified_at: Time.now, weekly_digest_email_enabled: false)
    create(:post, status: :published, published_at: 1.day.ago)

    assert_no_enqueued_emails do
      WeeklySummaryScheduleJob.perform_now
    end
  end
end
