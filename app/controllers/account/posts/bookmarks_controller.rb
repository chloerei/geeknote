class Account::Posts::BookmarksController < Account::Posts::BaseController
  before_action :require_authentication

  def create
    @post.bookmarks.find_or_create_by(user: Current.user)
    render turbo_stream: turbo_stream.replace(helpers.dom_id(@post, :bookmark), partial: "button", locals: { post: @post })
  end

  def destroy
    @post.bookmarks.where(user: Current.user).destroy_all
    render turbo_stream: turbo_stream.replace(helpers.dom_id(@post, :bookmark), partial: "button", locals: { post: @post })
  end
end
