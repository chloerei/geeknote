class Settings::ProfilesController < Settings::BaseController
  def show
  end

  def update
    if @user.update(user_params)
      redirect_to settings_profile_path, notice: "Profile updated"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :username, :bio, :avatar, :remove_avatar, :banner_image, :remove_banner_image)
  end
end
