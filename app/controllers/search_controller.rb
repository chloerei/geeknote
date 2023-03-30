class SearchController < ApplicationController
  def index
    if params[:query].present?
      @posts = Post.includes(:account, :user).search(params[:query], filter: "status = 'published'").page(params[:page])
    else
      @posts = Post.published.includes(:account, :user).order(score: :desc).page(params[:page])
    end
  end
end
