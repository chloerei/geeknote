class BookmarksController < ApplicationController
  before_action :require_sign_in

  def index
    @bookmarks = current_user.bookmarks.saved.order(id: :desc).page(params[:page])
  end

  def archived
    @bookmarks = current_user.bookmarks.archived.order(id: :desc).page(params[:page])
    render :index
  end

  def update
    @bookmark = current_user.bookmarks.find params[:id]
    @bookmark.update bookmark_params
    render turbo_stream: turbo_stream.remove("bookmark-#{@bookmark.id}")
  end

  def destroy
    @bookmark = current_user.bookmarks.find params[:id]
    @bookmark.destroy
    render turbo_stream: turbo_stream.remove("bookmark-#{@bookmark.id}")
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:status)
  end
end
