require "test_helper"

class Notification::CommentedTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "should send email if user email verified and enable email notification" do
    user = create(:user, email_verified_at: Time.now, email_notification_enabled: true)
    notification = Notification::Commented.create(user: user, comment: create(:comment))
    assert_enqueued_email_with UserMailer, :commented_notification, params: { notification: notification }
  end

  test "should not send email if user email not verified" do
    user = create(:user, email_verified_at: nil, email_notification_enabled: true)
    Notification::Commented.create(user: user, comment: create(:comment))
    assert_no_enqueued_emails
  end

  test "should not send email if user disable email notification" do
    user = create(:user, email_verified_at: Time.now, email_notification_enabled: false)
    Notification::Commented.create(user: user, comment: create(:comment))
    assert_no_enqueued_emails
  end
end
