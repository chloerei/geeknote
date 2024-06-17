class Settings::PasswordsController < Settings::BaseController
  def show
  end

  def update
    if @user.update(user_params.with_defaults(password_challenge: ""))
      redirect_to settings_password_path, notice: "Password was successfully updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation, :password_challenge)
  end
end
