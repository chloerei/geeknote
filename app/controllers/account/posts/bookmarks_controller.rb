class Account::Posts::BookmarksController < Account::Posts::BaseController
  before_action :require_sign_in

  def create
    @post.bookmarks.find_or_create_by(user: current_user)
    render turbo_stream: turbo_stream.replace("post-#{@post.id}-bookmark-button", partial: "button", locals: { post: @post })
  end

  def destroy
    @post.bookmarks.where(user: current_user).destroy_all
    render turbo_stream: turbo_stream.replace("post-#{@post.id}-bookmark-button", partial: "button", locals: { post: @post })
  end
end
