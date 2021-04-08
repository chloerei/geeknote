class Space::Dashboard::Posts::FeaturedImagesController < Space::Dashboard::Posts::BaseController
  def update
    @post.update post_params
    render turbo_stream: turbo_stream.replace('post-featured-image-form', partial: 'form')
  end

  def destroy
    @post.featured_image.purge_later
    render turbo_stream: turbo_stream.replace('post-featured-image-form', partial: 'form')
  end

  private

  def post_params
    params.require(:post).permit(:featured_image)
  end
end
