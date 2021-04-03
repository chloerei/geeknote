class Space::Dashboard::Posts::StatusesController < Space::Dashboard::Posts::BaseController
  def update
    @post.update post_params
  end

  private

  def post_params
    params.require(:post).permit(:status)
  end
end
