class Account::Dashboard::MembershipsController < Account::Dashboard::BaseController
  before_action :require_organization_account

  def index
    @memberships = @account.owner.memberships.includes(:user)
  end
end
