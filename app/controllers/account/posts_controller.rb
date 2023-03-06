class Account::PostsController < Account::BaseController
  def index
    @posts = scoped_posts.order(published_at: :desc).page(params[:page])
  end

  def show
    # member can read draft post
    @post = if current_member
      @account.posts.find params[:id]
    else
      @account.posts.published.find params[:id]
    end

    if params[:collection_id] && (collection = Collection.find_by id: params[:collection_id])
      if collection.can_read_by_user?(current_user)
        @collection = collection
      end
    end

    @pagination = RailsCursorPagination::Paginator.new(@post.comments.where(parent_id: nil).includes(:user), order_by: :likes_count, order: :desc).fetch
  end

  private

  def scoped_posts
    if @account.user?
      @account.owner.posts.published
    else
      @account.posts.published
    end
  end
end
