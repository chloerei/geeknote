class Settings::ProfilesController < Settings::BaseController
  def show
    @page_titles.prepend t("general.profile")
  end

  def update
    if @user.update(profile_params)
      redirect_to settings_profile_path, notice: t(".success")
    else
      render :show, status: :unprocessable_content
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :bio, :avatar, :remove_avatar, :banner_image, :remove_banner_image, account_attributes: [ :name ])
  end
end
