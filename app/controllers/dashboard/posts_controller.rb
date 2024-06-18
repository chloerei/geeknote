class Dashboard::PostsController < Dashboard::BaseController
  def index
    options = {}

    filters = []

    if @account.user?
      filters << "user_id = #{Current.user.id}"
    else
      if @member.owner? || @member.admin?
        filters << "account_id = #{@account.id}"
      else
        filters << "account_id = #{@account.id} AND user_id = #{Current.user.id}"
      end
    end

    @status = params[:status].presence_in(Post.statuses)
    if @status
      filters << "status = '#{@status}'"
    else
      filters << "status != 'trashed'"
    end

    options[:filter] = filters.join(" AND ")

    @sort = params[:sort].presence_in(%w[ updated created ]) || "created"
    case @sort
    when "updated"
      options[:sort] = [ "updated_at:desc" ]
    when "created"
      options[:sort] = [ "created_at:desc" ]
    end

    posts = post_scope.pagy_search(params[:q], options)

    @pagy, @posts = pagy_meilisearch(posts)
  end

  def new
    @post = @account.posts.new
    render layout: "application"
  end

  def create
    @post = @account.posts.new(post_params.merge(user: Current.user))

    if @post.save
      redirect_to edit_dashboard_post_path(@account.name, @post), notice: "Post was successfully created."
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
      redirect_to edit_dashboard_post_path(@account.name, @post), notice: "Post was successfully updated."
    else
      render :edit, layout: "application", status: :unprocessable_entity
    end
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
