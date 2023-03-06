class Account::Posts::CommentsController < Account::Posts::BaseController
  before_action :require_sign_in, except: [:index, :show]

  def index
    @pagination = RailsCursorPagination::Paginator.new(@post.comments.where(parent_id: params[:parent_id]).includes(:user), after: params[:after], order_by: :likes_count, order: :desc).fetch
  end

  def show
    @comment = @post.comments.find params[:id]
    @pagination = RailsCursorPagination::Paginator.new(@comment.replies.includes(:user), after: params[:after], order_by: :likes_count, order: :desc).fetch
  end

  def new
    @comment = @post.comments.new parent: (params[:parent_id] && @post.comments.find_by(id: params[:parent_id]))

    render turbo_stream: turbo_stream.append("comment-#{@comment.parent_id}-reply", partial: "form", locals: { comment: @comment })
  end

  def create
    @comment = Comment.new comment_params.merge(account: @account, commentable: @post, user: current_user)

    if @comment.save
      CommentNotificationJob.perform_later(@comment)
    else
      render turbo_stream: turbo_stream.replace("comment-#{@comment.parent_id}-reply-form", partial: 'form', locals: { comment: @comment })
    end
  end

  def edit
    @comment = @post.comments.where(user: current_user).find params[:id]
    render turbo_stream: turbo_stream.before("comment-#{@comment.id}-content", partial: "form", locals: { comment: @comment })
  end

  def update
    @comment = @post.comments.where(user: current_user).find params[:id]

    if @comment.update comment_params.except(:parent_id)
    else
      render turbo_stream: turbo_stream.replace("comment-#{@comment.id}-form", partial: 'form', locals: { comment: @comment })
    end
  end

  def destroy
    @comment = @post.comments.where(user: current_user).find params[:id]
    @comment.destroy
    render turbo_stream: turbo_stream.remove("comment-#{@comment.id}")
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :parent_id)
  end
end
