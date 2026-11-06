class BookmarksController < ApplicationController
  before_action :require_authentication

  def index
    @pagy, @posts = pagy(:offset, Current.user.bookmarked_posts.order("bookmarks.created_at DESC"))
    @page_titles.prepend t("general.bookmarks")
  end
end
