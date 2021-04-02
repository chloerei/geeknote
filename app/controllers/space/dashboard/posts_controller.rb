class Space::Dashboard::PostsController < Space::Dashboard::BaseController
  def index
  end

  def new
    @post = @space.posts.new
    render layout: 'base'
  end

  def create
    @post = @space.posts.new post_params.merge(author: current_user)
    @post.save!
    headers['Location'] = edit_space_dashboard_post_url(@space, @post)
  end

  private

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
