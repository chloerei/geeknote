class Account::Comments::LikesController < Account::Comments::BaseController
  def create
    @comment.likes.find_or_create_by(user: Current.user)
    render turbo_stream: turbo_stream.replace(helpers.dom_id(@comment, :like), partial: "account/comments/likes/button", locals: { comment: @comment, liked: true })
  end

  def destroy
    @comment.likes.where(user: Current.user).destroy_all
    render turbo_stream: turbo_stream.replace(helpers.dom_id(@comment, :like), partial: "account/comments/likes/button", locals: { comment: @comment, liked: false })
  end
end
