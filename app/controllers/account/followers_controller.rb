class Account::FollowersController < Account::BaseController
  def index
    @pagy, @accounts = pagy(@account.follower_accounts.order("follows.created_at DESC"), page: params[:page])
  end
end
