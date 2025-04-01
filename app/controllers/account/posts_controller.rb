class Account::PostsController < Account::BaseController
  def index
    posts = if @account.user?
      @account.owner.posts.published
    else
      @account.posts.published
    end

    @pagy, @posts = pagy(posts.order(published_at: :desc).includes(:account, :user))
  end

  def show
    @post = @account.posts.published.find params[:id]
  end
end
