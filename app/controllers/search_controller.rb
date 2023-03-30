class SearchController < ApplicationController
  def index
    if params[:query].present?
      @posts = Post.search(params[:query], filter: "status = 'published'").page(params[:page])
    end
  end
end
