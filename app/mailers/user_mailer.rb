class UserMailer < ApplicationMailer
  def password_reset_email
    @user = params[:user]

    mail(
      to: @user.email,
      subject: "Reset your GeekNote password"
    )
  end
end
