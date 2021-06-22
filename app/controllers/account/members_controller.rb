class Account::MembersController < Account::BaseController
  before_action :require_organization_account

  def index
    @members = @account.owner.members.includes(user: :account).order(role: :asc).page(params[:page])
  end
end
