class Account::Dashboard::MembersController < Account::Dashboard::BaseController
  before_action :require_organization_account
  before_action :require_account_admin, except: [:index, :show]
  before_action :set_member, only: [:show, :edit, :update, :destroy, :resend]

  def index
    @members = @account.owner.members.includes(user: :account).active
    @pending_members = @account.owner.members.pending
  end

  def new
    @member = Member.new role: :member
  end

  def create
    @member = @account.owner.members.new new_member_params.merge(inviter: current_user)

    if @member.save
      @member.touch(:invited_at)
      OrganizationMailer.with(member: @member).invitation_email.deliver_later
      redirect_to account_dashboard_member_path(@account, @member), notice: "Invitation send"
    else
      render turbo_stream: turbo_stream.replace('member-form', partial: 'form')
    end
  end

  def show
  end

  def edit
  end

  def update
    if @member.update edit_member_params
      redirect_to account_dashboard_member_path(@account, @member), notice: "Member updated"
    else
      render turbo_stream: turbo_stream.replace('member-form', partial: 'form')
    end
  end

  # admin can remove member
  # owner can remove owner and admin
  def destroy
    if current_role == 'owner' || @member.member?
      @member.destroy
    end
    redirect_to account_dashboard_members_path
  end

  def resend
    if @member.invitation_exipred?
      @member.regenerate_invitation_token
      @member.touch(:invited_at)
      OrganizationMailer.with(member: @member).invitation_email.deliver_later
    end
    redirect_to account_dashboard_member_path(@account, @member)
  end

  private

  # owner can add all roles
  # admin can add member role
  def new_member_params
    params.require(:member).permit(:identifier, :role).delete_if do |key, value|
      if key == 'role' && current_role != 'owner'
        !value.in?(%w(member))
      end
    end
  end

  def edit_member_params
    params.require(:member).permit(:role).delete_if do |key, value|
      if key == 'role' && current_role != 'owner'
        !value.in?(%w(member))
      end
    end
  end

  def set_member
    @member = @account.owner.members.find params[:id]
  end
end
