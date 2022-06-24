class Account::Dashboard::PostsController < Account::Dashboard::BaseController
  helper_method :post_filter_params

  before_action :set_post, only: [:edit, :update, :publish, :unpublish, :trash, :restore, :destroy]
  before_action :check_publish_permission, only: [:publish, :unpublish]

  def index
    @posts = scoped_posts.preload(:tags).order(updated_at: :desc).page(params[:page])

    if Post.statuses.include?(params[:status])
      @posts = @posts.where(status: params[:status])
    else
      @posts = @posts.not_trashed
    end

    if params[:tag]
      @posts = @posts.tagged_with(params[:tag])
    end
  end

  def new
    @post = @account.posts.new
  end

  def create
    @post = @account.posts.new post_params
    @post.save

    if params[:submit] == 'draft'
      redirect_to edit_account_dashboard_post_url(@account, @post), notice: 'Draft saved.'
    else
      @post.published!
      redirect_to account_post_url(@account, @post), notice: 'Post published.'
    end
  end

  def edit
  end

  def update
    @post.update post_params

    if params[:submit] == 'draft'
      redirect_to edit_account_dashboard_post_url(@account, @post), notice: 'Draft saved.'
    else
      @post.published!
      redirect_to account_post_url(@account, @post), notice: 'Post published.'
    end
  end

  def publish
    @post.published!
    @post.save_revision(status: 'published', user: current_user)
  end

  def unpublish
    @post.draft!
    redirect_to edit_account_dashboard_post_url(@account, @post), notice: I18n.t('flash.post_moved_to_draft')
  end

  def trash
    @post.trashed!
    redirect_to edit_account_dashboard_post_url(@account, @post), notice: I18n.t('flash.post_moved_to_trash')
  end

  def restore
    @post.draft!
    redirect_to edit_account_dashboard_post_url(@account, @post), notice: I18n.t('flash.post_moved_to_draft')
  end

  def destroy
    @post.destroy
    redirect_to account_dashboard_posts_url(@account)
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :featured_image, :remove_featured_image, tag_list: [])
  end

  def post_filter_params
    request.params.slice(:status)
  end

  def scoped_posts
    if current_member.has_permission?(:edit_other_post)
      @account.posts
    else
      @account.posts.joins(:authors).where(authors: { user: current_user })
    end
  end

  def set_post
    @post = scoped_posts.find params[:id]
  end

  def check_publish_permission
    unless current_member.has_permission?(:publish_other_post) || (current_member.has_permission?(:publish_own_post) && @post.authors.include?(current_user))
      render_not_found
    end
  end
end
