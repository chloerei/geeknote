class Admin::CommentsController < Admin::BaseController
  before_action :set_comment, only: [ :show, :edit, :update, :destroy ]

  def index
    @pagy, @comments = pagy(Comment.order(id: :desc).includes(:user))
  end

  def show
  end

  def edit
  end

  def update
    if @comment.update comment_params
      redirect_to admin_comment_path(@comment), notice: "Comment updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @comment.destroy
    redirect_to admin_comments_path, notice: "Comment deleted."
  end

  private

  def set_comment
    @comment = Comment.find params[:id]
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
