require "test_helper"

class FeedImportScheduleJobTest < ActiveJob::TestCase
  test "should enqueue FeedImportJob for account need to update" do
    # need update
    create(:user_account, feed_url: "https://example.com/fee.xml")
    create(:user_account, feed_url: "https://example.com/fee.xml", feed_fetched_at: 1.day.ago)

    # not need update
    create(:user_account, feed_url: nil)
    create(:user_account, feed_url: "https://example.com/fee.xml", feed_fetched_at: 1.hour.ago)

    assert_enqueued_jobs 2 do
      FeedImportScheduleJob.perform_now
    end
  end
end
