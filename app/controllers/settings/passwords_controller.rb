class Settings::PasswordsController < Settings::BaseController
  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update user_params
      redirect_to settings_password_path, notice: 'Password update successful'
    else
      render turbo_stream: turbo_stream.replace('password-form', partial: 'form')
    end
  end

  private

  def user_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
