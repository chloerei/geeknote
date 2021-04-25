class Account::Dashboard::MembershipsController < Account::Dashboard::BaseController
  before_action :require_organization_account
  before_action :require_account_admin, except: [:index, :show]
  before_action :set_membership, only: [:show, :edit, :update, :destroy, :resend]

  def index
    @memberships = @account.owner.memberships.includes(user: :account).active
    @pending_memberships = @account.owner.memberships.pending
  end

  def new
    @membership = Membership.new role: :member
  end

  def create
    @membership = @account.owner.memberships.new new_membership_params.merge(inviter: current_user)

    if @membership.save
      @membership.touch(:invited_at)
      OrganizationMailer.with(membership: @membership).invitation_email.deliver_later
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

  # admin can remove member
  # owner can remove owner and admin
  def destroy
    if current_role == 'owner' || @membership.member?
      @membership.destroy
    end
    redirect_to account_dashboard_memberships_path
  end

  def resend
    if @membership.invitation_exipred?
      @membership.regenerate_invitation_token
      @membership.touch(:invited_at)
      OrganizationMailer.with(membership: @membership).invitation_email.deliver_later
    end
    redirect_to account_dashboard_membership_path(@account, @membership)
  end

  private

  # owner can add all roles
  # admin can add member role
  def new_membership_params
    params.require(:membership).permit(:identifier, :role).delete_if do |key, value|
      if key == 'role' && current_role != 'owner'
        !value.in?(%w(member))
      end
    end
  end

  def edit_membership_params
    params.require(:membership).permit(:role).delete_if do |key, value|
      if key == 'role' && current_role != 'owner'
        !value.in?(%w(member))
      end
    end
  end

  def set_membership
    @membership = @account.owner.memberships.find params[:id]
  end
end
