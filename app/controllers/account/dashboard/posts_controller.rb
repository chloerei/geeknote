class Account::Dashboard::PostsController < Account::Dashboard::BaseController
  helper_method :post_filter_params

  before_action :set_post, only: [:edit, :update, :publish, :unpublish, :trash, :restore, :destroy]
  before_action :check_publish_permission, only: [:publish, :unpublish]

  def index
    @posts = scoped_posts.where(status: [:draft, :published]).order(updated_at: :desc).page(params[:page])
  end

  def new
    @post = @account.posts.new
  end

  def create
    @post = @account.posts.new post_params.merge(user: current_user)
    @post.save

    if params[:submit] == 'publish'
      @post.published!
    end

    redirect_to account_post_url(@account, @post)
  end

  def edit
  end

  def update
    @post.update post_params

    if params[:submit] == 'publish'
      @post.published!
    end

    redirect_to account_post_url(@account, @post)
  end

  def destroy
    @post.destroy
    render turbo_stream: turbo_stream.remove("post-item-#{@post.id}")
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :featured_image, :remove_featured_image, tag_list: [])
  end

  def scoped_posts
    if current_member.has_permission?(:edit_other_post)
      @account.posts
    else
      @account.posts.where(user: current_user )
    end
  end

  def set_post
    @post = scoped_posts.find params[:id]
  end

  def check_publish_permission
    unless current_member.has_permission?(:publish_other_post) || (current_member.has_permission?(:publish_own_post) && @post.user == current_user)
      render_not_found
    end
  end
end
