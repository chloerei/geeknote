class Account::Posts::LikesController < Account::Posts::BaseController
  before_action :require_sign_in

  def create
    @post.likes.find_or_create_by(user: current_user)
    render turbo_stream: turbo_stream.replace(helpers.dom_id(@post, :like), partial: "button", locals: { post: @post })
  end

  def destroy
    @post.likes.where(user: current_user).destroy_all
    render turbo_stream: turbo_stream.replace(helpers.dom_id(@post, :like), partial: "button", locals: { post: @post })
  end
end
