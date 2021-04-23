class Account::Dashboard::MembershipsController < Account::Dashboard::BaseController
  before_action :require_organization_account

  def index
    @memberships = @account.owner.memberships.includes(user: :account).accepted
    @invited_memberships = @account.owner.memberships.invited
  end

  def new
    @membership = Membership.new role: :member
  end

  def create
    @membership = @account.owner.memberships.new membership_params

    if @membership.save
      redirect_to account_dashboard_memberships_path
    else
      render turbo_stream: turbo_stream.replace('membership-form', partial: 'form')
    end
  end

  private

  def membership_params
    params.require(:membership).permit(:identifier, :role)
  end
end
