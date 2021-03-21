class Space::Dashboard::PostsController < Space::Dashboard::BaseController
  def index
  end

  def new
    @post = @space.posts.new
    render layout: 'base'
  end

  def create
  end
end
