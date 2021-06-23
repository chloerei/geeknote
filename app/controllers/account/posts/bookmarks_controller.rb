class Account::Posts::BookmarksController < Account::Posts::BaseController
  before_action :require_sign_in

  def create
    current_user.bookmarks.find_or_create_by(post: @post)
    @post.saved = true
    flash.now[:notice] = t('flash.bookmark_added')
    render :update
  end

  def destroy
    current_user.bookmarks.find_by(post: @post)&.destroy
    @post.saved = false
    flash.now[:notice] = t('flash.boomark_removed')
    render :update
  end
end
