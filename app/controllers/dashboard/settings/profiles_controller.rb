class Dashboard::Settings::ProfilesController < Dashboard::Settings::BaseController
  def show
  end

  def update
    if @account.owner.update(profile_params)
      redirect_to dashboard_settings_profile_path(@account.reload.name), notice: "Profile updated"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    if @account.user?
      params.require(:user).permit(:name, :bio, :avatar, :remove_avatar, :banner_image, :remove_banner_image, account_attributes: [ :name ])
    else
      params.require(:organization).permit(:name, :description, :avatar, :remove_avatar, :banner_image, :remove_banner_image, account_attributes: [ :name ])
    end
  end
end
