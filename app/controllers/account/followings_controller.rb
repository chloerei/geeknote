class Account::FollowingsController < Account::BaseController
  before_action :require_user_account

  def index
    @accounts = @account.owner.followings.page(params[:page])
  end
end
