class Settings::EmailsController < Settings::BaseController
  def show
    @page_titles.prepend t("general.email")
  end

  def update
    if @user.update(user_params.with_defaults(password_challenge: ""))
      if @user.email_previously_changed?
        UserMailer.with(user: @user).email_verification.deliver_later
      end
      redirect_to settings_email_path, notice: t(".success")
    else
      render :show, status: :unprocessable_entity
    end
  end

  def resend
    cache_key = "email_verification:#{current_user.email}"

    if Rails.cache.exist?(cache_key)
      redirect_to settings_email_path, notice: t(".already_sent")
    else
      Rails.cache.write(cache_key, true, expires_in: 1.minute)
      UserMailer.with(user: current_user).email_verification.deliver_later
      redirect_to settings_email_path, notice: t(".success")
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password_challenge)
  end
end
