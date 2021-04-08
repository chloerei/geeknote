class Space::Dashboard::Posts::ImagesController < Space::Dashboard::Posts::BaseController
  def update
    @post.update post_params
    render turbo_stream: turbo_stream.replace('post-image-form', partial: 'form')
  end

  def destroy
    @post.image.purge_later
    render turbo_stream: turbo_stream.replace('post-image-form', partial: 'form')
  end

  private

  def post_params
    params.require(:post).permit(:image)
  end
end
