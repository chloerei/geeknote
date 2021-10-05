require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "email verification" do
    user = create(:user)
    email = UserMailer.with(user: user).email_verification
    assert_equal [user.email], email.to
  end
end
