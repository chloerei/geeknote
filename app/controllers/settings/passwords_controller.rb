class Settings::PasswordsController < Settings::BaseController
  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.authenticate params[:user][:current_password]
      if @user.update user_params
        redirect_to settings_password_path, notice: t("flash.password_update_successful")
      else
        render :show, status: :unprocessable_entity
      end
    else
      @user.errors.add :current_password, :not_match
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
