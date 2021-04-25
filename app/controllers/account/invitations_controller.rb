class Account::InvitationsController < Account::BaseController
  layout 'base'
  before_action :require_organization_account, :set_membership
  before_action :require_sign_in, :check_user_match, only: [:update]

  def show
  end

  def update
    if @membership.update(user: current_user, status: :active, actived_at: Time.now)
      redirect_to account_dashboard_posts_path(@membership.organization.account)
    else
      redirect_to account_invitation_path(invitation_token: @membership.user_id_was ? nil : @membership.invitation_token)
    end
  end

  private

  def set_membership
    @membership = if params[:invitation_token]
      @account.owner.memberships.invitations.find_by user:nil, invitation_token: params[:invitation_token]
    elsif current_user
      @account.owner.memberships.invitations.find_by user: current_user
    end

    unless @membership
      render 'expired', status: :not_found
    end
  end

  def check_user_match
    if @membership.user && @membership.user != current_user
      redirect_to account_invitation_path, notice: 'User not match'
    end
  end
end
