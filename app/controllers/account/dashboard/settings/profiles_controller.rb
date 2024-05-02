class Account::Dashboard::Settings::ProfilesController < Account::Dashboard::Settings::BaseController
  def show
    @owner = @account.owner
  end

  def update
    @owner = @account.owner

    if params[:remove_banner_image]
      @owner.banner_image = nil
    end

    if @owner.update profile_params

      redirect_to account_dashboard_settings_profile_path(@account), notice: I18n.t("flash.profile_updated")
    else
      render turbo_stream: turbo_stream.replace("profile-form", partial: "form")
    end
  end

  private

  def profile_params
    if @account.organization?
      params.require(:organization).permit(:name, :description, :display_post_author, :banner_image, :avatar)
    else
      params.require(:user).permit(:name, :bio, :banner_image, :avatar)
    end
  end
end
