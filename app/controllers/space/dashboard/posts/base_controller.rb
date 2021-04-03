class Space::Dashboard::Posts::BaseController < Space::Dashboard::BaseController
  before_action :set_post

  private

  def set_post
    @post = @space.posts.find params[:post_id]
  end
end
