class Account::Posts::Comments::LikesController < Account::Posts::Comments::BaseController
  before_action :require_sign_in

  def create
    @comment.likes.find_or_create_by(user: current_user)
    @comment.liked = true
    render turbo_stream: turbo_stream.replace("comment-#{@comment.id}-like-button", partial: 'button', locals: { comment: @comment, liked: true })
  end

  def destroy
    @comment.likes.where(user: current_user).destroy_all
    @comment.liked = false
    render turbo_stream: turbo_stream.replace("comment-#{@comment.id}-like-button", partial: 'button', locals: { comment: @comment, liked: false })
  end
end
