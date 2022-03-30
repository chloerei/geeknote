class Account::PostsController < Account::BaseController
  def index
    @posts = scoped_posts.order(published_at: :desc).where(featured: false).page(params[:page])
  end

  def show
    @post = @account.posts.published.find params[:id]
    @revision = @post.revisions.published.last

    if params[:collection_id] && (collection = Collection.find_by id: params[:collection_id])
      if collection.can_read_by_user?(current_user)
        @collection = collection
      end
    end
  end

  private

  def scoped_posts
    if @account.user?
      @account.owner.author_posts.published
    else
      @account.posts.published
    end
  end
end
