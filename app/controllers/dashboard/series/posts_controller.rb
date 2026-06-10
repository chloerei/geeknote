class Dashboard::Series::PostsController < Dashboard::Series::BaseController
  before_action :set_post, only: [ :update ]

  def update
    @post.update(post_params)
  end

  private

  def set_post
    @post = @series.posts.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:position)
  end
end
