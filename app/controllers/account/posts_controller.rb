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

    @paginator = RailsCursorPagination::Paginator.new(@post.comments.where(parent_id: nil).includes(:user), order_by: :likes_count, order: :desc).fetch
  end
end
