class Account::Dashboard::BaseController < Account::BaseController
  before_action :require_sign_in, :require_account_member

  helper_method :current_role

  layout 'dashboard'

  private

  def current_role
    @current_role ||= if @account.organization?
      member = @account.owner.members.active.find_by(user: current_user)
      member ? member.role : ''
    else
      @account.owner == current_user ? 'owner' : ''
    end
  end

  def require_account_member
    unless current_role.in? %w(owner admin member)
      render_not_found
    end
  end

  def require_account_admin
    unless current_role.in? %w(owner admin)
      render_not_found
    end
  end

  def require_account_owner
    unless current_role.in? %w(owner)
      render_not_found
    end
  end
end
