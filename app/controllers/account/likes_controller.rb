class Account::LikesController < Account::BaseController
  before_action :require_user_account

  def index
    @posts = @account.owner.liked_posts.order("likes.created_at": :desc).page(params[:page])
  end
end
