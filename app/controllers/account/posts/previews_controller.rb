class Account::Posts::PreviewsController < Account::Posts::BaseController
  def show
    if ActiveSupport::SecurityUtils.secure_compare(@post.preview_token, params[:token])
      render 'account/posts/show'
    else
      render_not_found
    end
  end
end
