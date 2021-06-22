class Account::Dashboard::PostsController < Account::Dashboard::BaseController
  helper_method :post_filter_params

  def index
    @posts = scoped_posts.preload(:tags).order(updated_at: :desc).page(params[:page])

    if Post.statuses.include?(params[:status])
      @posts = @posts.where(status: params[:status])
    else
      @posts = @posts.not_trashed
    end

    if params[:tag]
      @posts = @posts.tagged_with(params[:tag])
    end
  end

  def new
    @post = @account.posts.new
    render 'editor', layout: 'base'
  end

  def create
    @post = @account.posts.new post_params.merge(author_users: [current_user])
    @post.save
    headers['Location'] = edit_account_dashboard_post_url(@account, @post)
  end

  def edit
    @post = scoped_posts.find params[:id]
    render 'editor', layout: 'base'
  end

  def update
    @post = scoped_posts.find params[:id]
    @post.update post_params

    if params[:submit] == 'preview'
      render :preview
    end
  end

  def destroy
    @post = scoped_posts.find params[:id]
    @post.destroy
    redirect_to account_dashboard_posts_url(@account)
  end

  private

  def post_params
    params.require(:post).permit(:title, :content)
  end

  def post_filter_params
    request.params.slice(:status)
  end

  def scoped_posts
    if current_member.has_permission?(:edit_other_post)
      @account.posts
    else
      @account.posts.joins(:authors).where(authors: { user: current_user })
    end
  end
end
