class BookmarksController < ApplicationController
  before_action :require_sign_in

  def index
    @pagy, @posts = pagy(Current.user.bookmarked_posts.order("bookmarks.created_at DESC"))
  end
end
