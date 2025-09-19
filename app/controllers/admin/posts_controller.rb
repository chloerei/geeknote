class Admin::PostsController < Admin::BaseController
  before_action :set_post, only: [ :show, :edit, :update, :restrict, :unrestrict, :destroy ]

  def index
    @pagy, @posts = pagy(Post.order(id: :desc).includes(:account, :user))
  end

  def show
  end

  def edit
  end

  def update
    if @post.update post_params
      redirect_to admin_post_path(@post), notice: "Post updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def restrict
    @post.restricted!
    redirect_to admin_post_path(@post), notice: "Post restricted."
  end

  def unrestrict
    @post.remove_restricted
    redirect_to admin_post_path(@post), notice: "Post remove restricted."
  end

  def destroy
    @post.destroy
    redirect_to admin_posts_path, notice: "Post deleted."
  end

  private

  def set_post
    @post = Post.find params[:id]
  end

  def post_params
    params.require(:post).permit(:title, :content, :canonical_url)
  end
end
