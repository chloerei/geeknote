class Settings::EmailsController < Settings::BaseController
  def show
    @user = current_user
  end

  def update
    @user = current_user
    @user.require_password = true
    if @user.update user_params
      redirect_to settings_email_path, notice: t('flash.account_update_successful')
    else
      render turbo_stream: turbo_stream.replace('account-form', partial: 'form')
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :current_password, account_attributes: [:path])
  end
end
