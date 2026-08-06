class Settings::AccountDeletionsController < Settings::BaseController
  before_action :set_organizations

  def show
    @page_titles.prepend t("general.delete_account")
  end

  def create
    if @organizations.any?
      flash.now[:alert] = t(".must_leave_organizations")
      render :show, status: :unprocessable_content
    elsif params[:name] == @user.account.name
      UserDeletionJob.perform_later(@user)
      terminate_session
      redirect_to account_deleted_path
    else
      flash.now[:alert] = t(".account_name_mismatch")
      render :show, status: :unprocessable_content
    end
  end

  private

  def set_organizations
    @organizations = Current.user.organizations
  end
end
