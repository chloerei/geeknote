class Account::Dashboard::MembershipsController < Account::Dashboard::BaseController
  before_action :require_organization_account
  before_action :set_membership, only: [:show, :edit, :update, :destroy]

  def index
    @memberships = @account.owner.memberships.includes(user: :account).active
    @pending_memberships = @account.owner.memberships.pending
  end

  def new
    @membership = Membership.new role: :member
  end

  def create
    @membership = @account.owner.memberships.new new_membership_params

    if @membership.save
      redirect_to account_dashboard_membership_path(@account, @membership), notice: "Invitation send"
    else
      render turbo_stream: turbo_stream.replace('membership-form', partial: 'form')
    end
  end

  def show
  end

  def edit
  end

  def update
    if @membership.update edit_membership_params
      redirect_to account_dashboard_membership_path(@account, @membership), notice: "Membership updated"
    else
      render turbo_stream: turbo_stream.replace('membership-form', partial: 'form')
    end
  end

  def destroy
    @membership.destroy
    redirect_to account_dashboard_memberships_path
  end

  private

  def new_membership_params
    params.require(:membership).permit(:identifier, :role)
  end

  def edit_membership_params
    params.require(:membership).permit(:role)
  end

  def set_membership
    @membership = @account.owner.memberships.find params[:id]
  end
end
