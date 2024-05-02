class Account::FollowersController < Account::BaseController
  def index
    @paginator = RailsCursorPagination::Paginator.new(@account.follows.includes(user: [ :account ]), order_by: :created_at, order: :desc, after: params[:after]).fetch
  end
end
