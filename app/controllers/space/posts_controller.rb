class Space::PostsController < Space::BaseController
  def index
  end

  def show
    @post = @space.posts.find params[:id]
  end
end
