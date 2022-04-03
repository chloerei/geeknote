require "test_helper"

class FeedImportScheduleJobTest < ActiveJob::TestCase
  test "should enqueue FeedImportJob for account need to update" do
    # need update
    create(:user_account, feed_url: 'https://example.com/fee.xml')

    # not need update
    create(:user_account, feed_url: nil)

    assert_enqueued_jobs 1 do
      FeedImportScheduleJob.perform_now
    end
  end
end
