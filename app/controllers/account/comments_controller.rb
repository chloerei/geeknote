class Account::CommentsController < Account::BaseController
  before_action :require_user_account
  before_action :require_authentication, except: [ :show ]
  before_action :require_author, except: [ :index, :show ]

  def index
    @pagy, @comments = pagy(@account.owner.comments.includes(:user).order(created_at: :desc))
  end

  def show
    @comment = @account.owner.comments.find params[:id]

    comments = @comment.replies

    @sort = params[:sort].presence_in(%w[ oldest popular ]) || "newest"

    comments = case @sort
    when "oldest"
      comments.order(created_at: :asc)
    when "popular"
      comments.order(likes_count: :desc, created_at: :desc)
    else
      comments.order(created_at: :desc)
    end

    @pagy, @comments = pagy(comments.includes(:user))

    @page_titles.prepend t("general.comments")
  end

  def create
    @comment = @account.owner.comments.new params.require(:comment).permit(:content, :commentable_sgid, :parent_id)

    if @comment.save
      new_comment = @account.owner.comments.new(commentable: @comment.commentable, parent: @comment.parent)
      render turbo_stream: [
        turbo_stream.prepend("comments_list", partial: "comment", locals: { comment: @comment }),
        turbo_stream.replace(helpers.dom_id(new_comment, :form), partial: "form", locals: { comment: new_comment })
      ]
    else
      render turbo_stream: turbo_stream.replace(helpers.dom_id(@comment, :form), partial: "form", locals: { comment: @comment })
    end
  end

  def edit
    @comment = @account.owner.comments.find params[:id]
  end

  def update
    @comment = @account.owner.comments.find params[:id]

    if @comment.update(params.require(:comment).permit(:content))
      redirect_to account_comment_path(@account.name, @comment), notice: "Comment updated"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @comment = @account.owner.comments.find params[:id]
    @comment.destroy
    render turbo_stream: turbo_stream.remove(@comment)
  end

  private

  def require_author
    if Current.user.account != @account
      redirect_to root_path, alert: "You are not allowed to access this page"
    end
  end
end
