# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def password_reset_email
    @user = User.first || FactoryBot.create(:user)
    UserMailer.with(user: @user).password_reset_email
  end

  def post_restricted_email
    @user = User.first || FactoryBot.create(:user)
    @post = Post.first || FactoryBot.create(:post)
    UserMailer.with(user: @user, post: @post).post_restricted_email
  end

  def email_verification
    @user = User.first || FactoryBot.create(:user)
    UserMailer.with(user: @user).email_verification
  end

  def commented_notification
    notification = Notification::Commented.first || FactoryBot.create(:commented_notification)

    UserMailer.with(notification: notification).commented_notification
  end

  def post_blocked_notification
    notification = Notification::PostBlocked.first || FactoryBot.create(:post_blocked_notification)

    UserMailer.with(notification: notification).post_blocked_notification
  end

  def weekly_digest
    user = User.first || FactoryBot.create(:user)

    UserMailer.with(user: user).weekly_digest
  end
end
