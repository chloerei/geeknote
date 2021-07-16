# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def password_reset_email
    @user = User.first || FactoryBot.create(:user)
    UserMailer.with(user: @user).password_reset_email
  end
end
