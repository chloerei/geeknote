class Space::Posts::BaseController < Space::BaseController
  before_action :set_post

  private

  def set_post
    @post = @space.posts.find params[:post_id]
  end
end
