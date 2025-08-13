class Account::Posts::LikesController < Account::Posts::BaseController
  before_action :require_authentication

  def create
    @post.likes.find_or_create_by(user: Current.user)
    render turbo_stream: turbo_stream.replace(helpers.dom_id(@post, :like), partial: "button", locals: { post: @post })
  end

  def destroy
    @post.likes.where(user: Current.user).destroy_all
    render turbo_stream: turbo_stream.replace(helpers.dom_id(@post, :like), partial: "button", locals: { post: @post })
  end
end
