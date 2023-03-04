class Account::Posts::CommentsController < Account::Posts::BaseController
  before_action :require_sign_in, except: [:index, :show]

  def index
    @comments = @post.comments.with_liked(current_user).order(created_at: :desc).page(params[:page])
  end

  def show
    @comment = @post.comments.find params[:id]
    @replies = @comment.replies.with_liked(current_user).order(created_at: :desc).page(params[:page])
  end

  def new
    @comment = @post.comments.new parent: (params[:parent_id] && @post.comments.find_by(id: params[:parent_id]))

    if @comment.parent
      render turbo_stream: turbo_stream.update("comment-#{@comment.parent.id}-reply-form", partial: "form", locals: { comment: @comment })
    else
      render turbo_stream: turbo_stream.update("comment-reply-form", partial: "form", locals: { comment: @comment })
    end
  end

  def create
    @comment = Comment.new comment_params.merge(account: @account, commentable: @post, user: current_user)

    if @comment.save
      CommentNotificationJob.perform_later(@comment)
      render :create
    else
      render turbo_stream: turbo_stream.replace('comment-form', partial: 'form', locals: { comment: @comment })
    end
  end

  def edit
    @comment = @post.comments.where(user: current_user).find params[:id]
  end

  def update
    @comment = @post.comments.where(user: current_user).find params[:id]

    if @comment.update comment_params.except(:parent_id)
      redirect_to account_post_comment_path(@account, @post, @comment)
    else
      render turbo_stream: turbo_stream.replace('comment-form', partial: 'form', locals: { comment: @comment })
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
