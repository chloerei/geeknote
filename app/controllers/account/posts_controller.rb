class Account::PostsController < Account::BaseController
  def index
    @posts = scoped_posts.order(published_at: :desc).where(featured: false).page(params[:page])
  end

  def show
    @post = scoped_posts.find params[:id]

    if params[:collection_id] && (collection = Collection.find_by id: params[:collection_id])
      if collection.can_read_by_user?(current_user)
        @collection = collection
      end
    end
  end

  private

  def scoped_posts
    if @account.user?
      @account.owner.author_posts.published.with_statuses(current_user)
    else
      @account.posts.published.with_statuses(current_user)
    end
  end
end
