class Account::Dashboard::MembersController < Account::Dashboard::BaseController
  before_action :require_organization_account
  helper_method :can_manage?

  before_action do
    unless current_member.has_permission?(:manage_member)
      render_not_found
    end
  end

  before_action :set_member, only: [:show, :edit, :update, :destroy, :resend]

  def index
    @members = @account.owner.members.includes(user: :account).active
    @pending_members = @account.owner.members.pending
  end

  def new
    @member = Member.new role: :contributor
  end

  def create
    @member = @account.owner.members.new new_member_params.merge(inviter: current_user)

    if can_manage?(@member) && @member.save
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
    if can_manage?(@member)
      @member.assign_attributes(edit_member_params)
    end

    if can_manage?(@member) && @member.save
      redirect_to account_dashboard_member_path(@account, @member), notice: "Member updated"
    else
      render turbo_stream: turbo_stream.replace('member-form', partial: 'form')
    end
  end

  # admin can remove member
  # owner can remove owner and admin
  def destroy
    if can_manage?(@member)
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

  def new_member_params
    params.require(:member).permit(:identifier, :role)
  end

  def edit_member_params
    params.require(:member).permit(:role)
  end

  def can_manage?(member)
    case current_member.role
    when 'owner'
      true
    when 'admin'
      member.role.in? %w(editor writer contributor)
    when 'editor'
      member.role.in? %w(writer contributor)
    else
      false
    end
  end

  def set_member
    @member = @account.owner.members.find params[:id]
  end
end
