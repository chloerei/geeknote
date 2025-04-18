class Dashboard::PostsController < Dashboard::BaseController
  helper_method :account_posts

  def index
    posts = account_posts

    @status = params[:status].presence_in(%w[draft published trashed]) || "draft"
    posts = posts.where(status: @status).order(updated_at: :desc)

    @pagy, @posts = pagy(posts)

    @page_titles.prepend t("general.posts")
  end

  def new
    @post = @account.posts.new
    @page_titles.prepend t("general.new_post")

    render layout: "application"
  end

  def create
    @post = @account.posts.new(post_params.merge(user: Current.user))

    if @post.save
      redirect_to edit_dashboard_post_path(@account.name, @post), notice: t(".success")
    else
      render :edit, layout: "application", status: :unprocessable_entity
    end
  end

  def edit
    @post = account_posts.find(params[:id])
    @page_titles.prepend t("general.edit_post")
    render layout: "application"
  end

  def update
    @post = account_posts.find(params[:id])

    if @post.update(post_params)
      redirect_to edit_dashboard_post_path(@account.name, @post), notice: t(".success")
    else
      render :edit, layout: "application", status: :unprocessable_entity
    end
  end

  def destroy
    @post = account_posts.find(params[:id])
    @post.destroy
    redirect_to dashboard_posts_path(@account.name), notice: t(".success")
  end

  def preview
    @post = Post.new(post_params)
    render layout: false
  end

  private

  def account_posts
    if @account.user?
      Current.user.posts
    else
      if @member.owner? || @member.admin?
        @account.posts
      else
        @account.posts.where(user: Current.user)
      end
    end
  end

  def post_params
    params.require(:post).permit(:title, :content, :featured_image, :remove_featured_image, :tag_list, :canonical_url, :allow_comments)
  end
end
