class Dashboard::PostsController < Dashboard::BaseController
  def index
    posts = post_scope

    @status = params[:status].presence_in(Post.statuses)
    if @status
      posts = posts.where(status: @status)
    else
      posts = posts.where.not(status: "trashed")
    end

    @sort = params[:sort].presence_in(%w[ updated created ]) || "created"
    case @sort
    when "updated"
      posts = posts.order(updated_at: :desc)
    when "created"
      posts = posts.order(created_at: :desc)
    end

    if params[:q].present?
      posts = posts.where("title ILIKE ?", "%#{params[:q]}%")
    end

    @pagy, @posts = pagy(posts)
  end

  def new
    @post = @account.posts.new
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
    @post = post_scope.find(params[:id])
    render layout: "application"
  end

  def update
    @post = post_scope.find(params[:id])

    if @post.update(post_params)
      redirect_to edit_dashboard_post_path(@account.name, @post), notice: t(".success")
    else
      render :edit, layout: "application", status: :unprocessable_entity
    end
  end

  def destroy
    @post = post_scope.find(params[:id])
    @post.destroy
    redirect_to dashboard_posts_path(@account.name), notice: t(".success")
  end

  def preview
    @post = Post.new(post_params)
    render layout: false
  end

  private

  def post_scope
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
    params.require(:post).permit(:title, :content, :featured_image, :remove_featured_image, :tag_list, :canonical_url)
  end
end
