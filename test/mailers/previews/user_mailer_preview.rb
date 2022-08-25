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

  def comment_notification
    user = User.first || FactoryBot.create(:user)
    comment = Comment.first || FactoryBot.create(:comment)

    UserMailer.with(user: user, comment: comment).comment_notification
  end

  def weekly_summary
    user = User.first || FactoryBot.create(:user)

    UserMailer.with(user: user).weekly_summary
  end
end
