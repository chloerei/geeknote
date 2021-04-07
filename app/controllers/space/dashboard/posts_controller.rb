class Space::Dashboard::PostsController < Space::Dashboard::BaseController
  def index
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

  private

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
