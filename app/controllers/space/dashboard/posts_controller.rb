class Space::Dashboard::PostsController < Space::Dashboard::BaseController
  helper_method :post_filter_params

  def index
    @posts = @space.posts.order(updated_at: :desc).page(params[:page])

    if Post.statuses.include?(params[:status])
      @posts = @posts.where(status: params[:status])
    else
      @posts = @posts.not_trashed
    end
  end

  def new
    @post = @space.posts.new
    render 'editor', layout: 'base'
  end

  def create
    @post = @space.posts.new post_params.merge(author: current_user)
    @post.save
    headers['Location'] = edit_space_dashboard_post_url(@space, @post)
  end

  def edit
    @post = @space.posts.find params[:id]
    render 'editor', layout: 'base'
  end

  def update
    @post = @space.posts.find params[:id]
    @post.update post_params

    if params[:submit] == 'preview'
      render :preview
    end
  end

  def destroy
    @post = @space.posts.find params[:id]
    @post.destroy
    redirect_to space_dashboard_posts_url(@space)
  end

  private

  def post_params
    params.require(:post).permit(:title, :content)
  end

  def post_filter_params
    request.params.slice(:status)
  end
end
