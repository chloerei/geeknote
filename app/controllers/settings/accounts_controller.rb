class Settings::AccountsController < Settings::BaseController
  def show
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update user_params
      redirect_to settings_account_path, notice: 'Account update successful'
    else
      render turbo_stream: turbo_stream.replace('account-form', partial: 'form')
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :current_password, account_attributes: [:path])
  end
end
