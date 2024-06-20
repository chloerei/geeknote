class Dashboard::Settings::BaseController < Dashboard::BaseController
  before_action :require_account_admin

  private

  def require_account_admin
    if @account.user?
      unless @account.owner == Current.user
        redirect_to dashboard_root_path(@account.name), alert: "You are not allowed to access this page"
      end
    else
      unless @member.role.in?(["owner", "admin"])
        redirect_to dashboard_root_path(@account.name), alert: "You are not allowed to access this page"
      end
    end
  end
end
