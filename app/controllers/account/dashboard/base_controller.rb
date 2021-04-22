class Account::Dashboard::BaseController < Account::BaseController
  private

  def require_organization_account
    unless @account.organization?
      render_not_found
    end
  end
end
