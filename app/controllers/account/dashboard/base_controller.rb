class Account::Dashboard::BaseController < Account::BaseController
  before_action :require_sign_in, :require_account_member

  layout 'dashboard'

  private

  def require_account_member
    unless current_member
      render_not_found
    end
  end
end
