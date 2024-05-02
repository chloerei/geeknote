class Account::Dashboard::MembersController < Account::Dashboard::BaseController
  before_action :require_organization_account, :require_manage_permission
  before_action :set_member, only: [ :show, :edit, :update, :destroy, :resend ]

  helper_method :can_manage?

  def index
    @members = @account.owner.members.includes(user: :account).order(status: :asc, created_at: :desc)
  end

  def new
    @member = Member.new role: "member"
  end

  def create
    @member = @account.owner.members.new member_params.merge(inviter: current_user, invited_at: Time.now)

    if @member.save
      OrganizationMailer.with(member: @member).invitation_email.deliver_later
      redirect_to account_dashboard_member_path(@account, @member), notice: "Invitation send"
    else
      render :new, status: :unprocessable_entity
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
      render turbo_stream: turbo_stream.replace("member-form", partial: "form")
    end
  end

  def destroy
    if can_manage?(@member) && !@member.owner?
      @member.destroy
    end
    redirect_to account_dashboard_members_path
  end

  def resend
    if @member.invited_at > 1.minute.ago
      flash[:notice] = I18n.t("flash.please_wait_one_minute_to_resend_invitation")
    else
      @member.regenerate_invitation_token
      @member.touch(:invited_at)
      OrganizationMailer.with(member: @member).invitation_email.deliver_later
      flash[:notice] = I18n.t("flash.invitation_has_been_sent")
    end

    redirect_to account_dashboard_member_path(@account, @member)
  end

  private

  def member_params
    case current_member.role
    when "owner"
      params.require(:member).permit(:invitation_email, :role)
    else
      params.require(:member).permit(:invitation_email)
    end
  end

  def require_manage_permission
    unless current_member.role.in?(%w[owner admin])
      render_not_found
    end
  end

  def can_manage?(member)
    case current_member.role
    when "owner"
      true
    when "admin"
      member.role.in? %w[member]
    else
      false
    end
  end

  def set_member
    @member = @account.owner.members.find params[:id]
  end
end
