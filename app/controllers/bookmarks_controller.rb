class BookmarksController < ApplicationController
  before_action :require_sign_in

  def index
    @posts = current_user.bookmarked_posts.published.order("bookmarks.created_at": :desc).page(params[:page])
  end
end
