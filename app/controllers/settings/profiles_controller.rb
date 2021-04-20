class Settings::ProfilesController < Settings::BaseController
  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update user_params
      redirect_to settings_profile_path, notice: 'Profile update successful'
    else
      render turbo_stream: turbo_stream.replace('profile-form', partial: 'form')
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :bio, :avatar)
  end
end
