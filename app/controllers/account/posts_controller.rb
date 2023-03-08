class Account::PostsController < Account::BaseController
  def index
    @posts = if @account.user?
      @account.owner.posts.published
    else
      @account.posts.published
    end

    @pagination = RailsCursorPagination::Paginator.new(@posts.preload(:account, :user), order_by: :published_at, order: :desc, after: params[:after]).fetch
  end

  def show
    @post = @account.posts.published.find params[:id]

    if params[:collection_id] && (collection = Collection.find_by id: params[:collection_id])
      if collection.can_read_by_user?(current_user)
        @collection = collection
      end
    end

    @pagination = RailsCursorPagination::Paginator.new(@post.comments.where(parent_id: nil).includes(:user), order_by: :likes_count, order: :desc).fetch
  end
end
