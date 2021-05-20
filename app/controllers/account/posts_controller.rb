class Account::PostsController < Account::BaseController
  def index
    @posts = scoped_posts.order(updated_at: :desc).page(params[:page])
  end

  def show
    @post = scoped_posts.find params[:id]
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
