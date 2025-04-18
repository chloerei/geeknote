class Account::FollowingsController < Account::BaseController
  before_action :require_user_account

  def index
    @pagy, @accounts = pagy(@account.owner.followings.includes(:owner).order("follows.created_at DESC"), page: params[:page])
    @page_titles.prepend t("general.following")
  end

  private

  def require_user_account
    redirect_to account_root_path(@account) unless @account.user?
  end
end
