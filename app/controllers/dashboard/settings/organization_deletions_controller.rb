class Dashboard::Settings::OrganizationDeletionsController < Dashboard::Settings::BaseController
  before_action :require_organization_account

  def show
    @page_titles.prepend t("general.delete_organization")
  end

  def create
    if params[:name] == @organization.account.name
      OrganizationDeletionJob.perform_later(@organization)
      redirect_to organizations_path, notice: t(".scheduled")
    else
      flash.now[:alert] = t(".account_name_mismatch")
      render :show, status: :unprocessable_content
    end
  end
end
