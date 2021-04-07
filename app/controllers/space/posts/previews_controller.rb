class Space::Posts::PreviewsController < Space::Posts::BaseController
  def show
    if ActiveSupport::SecurityUtils.secure_compare(@post.preview_token, params[:token])
      render 'space/posts/show'
    else
      render_not_found
    end
  end
end
