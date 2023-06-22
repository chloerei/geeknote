class BookmarksController < ApplicationController
  before_action :require_sign_in

  def index
    @posts = current_user.bookmarked_posts.published.order("bookmarks.created_at": :desc).page(params[:page])

    if params[:tag]
      @posts = @posts.tagged_with(params[:tag])
    end
  end
end
