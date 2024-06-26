require "test_helper"

class Notification::PostBlockedTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "should send email if user email verified" do
    user = create(:user, email_verified_at: Time.now)
    notification = Notification::PostBlocked.create(user: user, post: create(:post))
    assert_enqueued_email_with UserMailer, :post_blocked_notification, params: { notification: notification }
  end
end
