class Dashboard::Settings::ProfilesController < Dashboard::Settings::BaseController
  before_action :require_organization_account

  def show
    @page_titles.prepend t("general.profile")
  end

  def update
    if @organization.update(profile_params)
      redirect_to dashboard_settings_profile_path(@account.reload.name), notice: "Profile updated"
    else
      render :show, status: :unprocessable_content
    end
  end

  private

  def profile_params
    params.require(:organization).permit(:name, :description, :avatar, :banner_image, account_attributes: [ :name ])
  end
end
