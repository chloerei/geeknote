class Account::Posts::BookmarksController < Account::Posts::BaseController
  before_action :require_sign_in

  def create
    current_user.bookmarks.create(post: @post)
    @post.saved = true
    render turbo_stream: turbo_stream.replace("post-#{@post.id}-bookmark-button", partial: 'button', locals: { post: @post })
  end

  def destroy
    current_user.bookmarks.find_by(post: @post)&.destroy
    @post.saved = false
    render turbo_stream: turbo_stream.replace("post-#{@post.id}-bookmark-button", partial: 'button', locals: { post: @post })
  end
end
