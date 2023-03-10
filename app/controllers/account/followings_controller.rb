class Account::FollowingsController < Account::BaseController
  before_action :require_user_account

  def index
    @paginator = RailsCursorPagination::Paginator.new(@account.owner.follows.includes(:account), order_by: :created_at, order: :desc, after: params[:after]).fetch
  end
end
