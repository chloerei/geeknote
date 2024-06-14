class Account::PostsController < Account::BaseController
  def index
    @posts = if @account.user?
      @account.owner.posts.published
    else
      @account.posts.published
    end

    @paginator = RailsCursorPagination::Paginator.new(@posts.preload(:account, :user), order_by: :published_at, order: :desc, after: params[:after]).fetch
  end

  def show
    @post = @account.posts.published.find params[:id]

    @paginator = RailsCursorPagination::Paginator.new(@post.comments.where(parent_id: nil).includes(:user), order_by: :likes_count, order: :desc).fetch
  end
end
