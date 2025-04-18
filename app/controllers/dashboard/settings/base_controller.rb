class Dashboard::Settings::BaseController < Dashboard::BaseController
  before_action :require_account_admin
  before_action :set_title

  private

  def require_account_admin
    if @account.user?
      unless @account.owner == Current.user
        redirect_to dashboard_root_path(@account.name), alert: "You are not allowed to access this page"
      end
    else
      unless @member.role.in?([ "owner", "admin" ])
        redirect_to dashboard_root_path(@account.name), alert: "You are not allowed to access this page"
      end
    end
  end

  def require_organization_account
    if !@account.organization?
      redirect_to dashboard_settings_root_path, alert: "You are not allowed to access this page"
    else
      @organization = @account.owner
    end
  end

  def set_title
    @page_titles.prepend t("general.settings")
  end
end
