class Admin::CommentsController < Admin::BaseController
  before_action :set_comment, only: [ :show, :edit, :update ]

  def index
    @comments = Comment.order(id: :desc).includes(:user).page(params[:page])
  end

  def show
  end

  def edit
  end

  def update
    if @comment.update comment_params
      redirect_to admin_comment_path(@comment), notice: "Comment updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_comment
    @comment = Comment.find params[:id]
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
