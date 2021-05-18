class Account::FollowersController < Account::BaseController
  def index
    @accounts = @account.follower_accounts.page(params[:page])
  end
end
