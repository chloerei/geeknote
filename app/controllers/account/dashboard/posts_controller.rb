class Account::Dashboard::PostsController < Account::Dashboard::BaseController
  helper_method :post_filter_params

  before_action :set_post, only: [:edit, :update, :publish, :unpublish, :trash, :restore, :destroy]

  def index
    @posts = scoped_posts.where(status: [:draft, :published]).order(updated_at: :desc).page(params[:page])
  end

  def new
    @post = @account.posts.new

    render :editor, layout: 'base'
  end

  def create
    @post = @account.posts.new post_params.merge(user: current_user)
    @post.save
    redirect_to edit_account_dashboard_post_path(@account, @post), notice: I18n.t("flash.post_is_saved")
  end

  def edit
    render :editor, layout: 'base'
  end

  def update
    @post.update post_params
    render :update
  end

  def destroy
    @post.destroy
    render turbo_stream: turbo_stream.remove("post-item-#{@post.id}")
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :featured_image, :remove_featured_image, :status, :canonical_url, tag_list: [])
  end

  def scoped_posts
    if current_member.role.in?(%w(owner admin))
      @account.posts
    else
      @account.posts.where(user: current_user)
    end
  end

  def set_post
    @post = scoped_posts.find params[:id]
  end
end
