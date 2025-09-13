class Account::InvitationsController < Account::BaseController
  layout "application"
  before_action :require_organization_account, :set_member
  before_action :require_authentication, :check_user_match, only: [ :update ]

  def show
  end

  def update
    if @member.update(user: Current.user, status: :active, actived_at: Time.now)
      redirect_to dashboard_posts_path(@account.name, @member.organization.account.name)
    else
      redirect_to account_invitation_path(invitation_token: @member.invitation_token)
    end
  end

  private

  def set_member
    @member = @account.owner.members.pending.find_by user: nil, invitation_token: params[:invitation_token]

    unless @member && @member.invited_at > 7.days.ago
      render "expired", status: :not_found
    end
  end

  def check_user_match
    if @member.user && @member.user != Current.user
      redirect_to account_invitation_path, notice: "User not match"
    end
  end
end
