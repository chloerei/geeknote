class SearchController < ApplicationController
  def index
    if params[:query].present?
      @posts = Post.search(params[:query], filter: "status = 'published'").page(params[:page])
    else
      @posts = Post.published.order(score: :desc).page(params[:page])
    end
  end
end
