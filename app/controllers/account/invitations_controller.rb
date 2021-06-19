class Account::InvitationsController < Account::BaseController
  layout 'base'
  before_action :require_organization_account, :set_member
  before_action :require_sign_in, :check_user_match, only: [:update]

  def show
  end

  def update
    if @member.update(user: current_user, status: :active, actived_at: Time.now)
      redirect_to account_dashboard_posts_path(@member.organization.account)
    else
      redirect_to account_invitation_path(invitation_token: @member.user_id_was ? nil : @member.invitation_token)
    end
  end

  private

  def set_member
    @member = if params[:invitation_token]
      @account.owner.members.invitations.find_by user:nil, invitation_token: params[:invitation_token]
    elsif current_user
      @account.owner.members.invitations.find_by user: current_user
    end

    unless @member
      render 'expired', status: :not_found
    end
  end

  def check_user_match
    if @member.user && @member.user != current_user
      redirect_to account_invitation_path, notice: 'User not match'
    end
  end
end
