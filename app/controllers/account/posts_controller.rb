class Account::PostsController < Account::BaseController
  def index
    @posts = scoped_posts.order(published_at: :desc).page(params[:page])
  end

  def show
    @post = scoped_posts.find params[:id]
  end

  private

  def scoped_posts
    if @account.user?
      @account.owner.posts.published.with_statuses(current_user)
    else
      @account.posts.published.with_statuses(current_user)
    end
  end
end
