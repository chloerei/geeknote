class Account::Posts::PreviewsController < Account::Posts::BaseController
  def show
    if ActiveSupport::SecurityUtils.secure_compare(@post.preview_token, params[:token].to_s) && !@post.restricted
      @revision = @post.revisions.last
      render 'account/posts/show'
    else
      render_not_found
    end
  end
end
