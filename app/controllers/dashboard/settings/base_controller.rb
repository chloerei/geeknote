class Dashboard::Settings::BaseController < Dashboard::BaseController
  before_action :require_account_admin

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
      redirect_to dashboard_settings_profile_path, alert: "You are not allowed to access this page"
    else
      @organization = @account.owner
    end
  end
end
