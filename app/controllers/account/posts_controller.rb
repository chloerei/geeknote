class Account::PostsController < Account::BaseController
  def index
    @posts = @account.posts.order(updated_at: :desc).page(params[:page])
  end

  def show
    @post = @account.posts.find params[:id]
  end
end
