class Account::Dashboard::Settings::ProfilesController < Account::Dashboard::Settings::BaseController
  def show
    @owner = @account.owner
  end

  def update
    @owner = @account.owner

    if @owner.update profile_params
      # do nothing
      redirect_to account_dashboard_settings_profile_path(@account), notice: 'Profile updated'
    else
      render turbo_stream: turbo_stream.replace('profile-form', partial: 'form')
    end
  end

  private

  def profile_params
    if @account.organization?
      params.require(:organization).permit(:name, :description, :display_post_author, account_attributes: [:name])
    else
      params.require(:user).permit(:name, :bio, account_attributes: [:name])
    end
  end
end
