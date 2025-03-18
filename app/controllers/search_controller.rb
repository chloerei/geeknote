class SearchController < ApplicationController
  helper_method :search_params

  def index
    @type = params[:type].presence_in(%w[posts comments accounts]) || "posts"

    options = {}

    @sort = params[:sort].presence_in(%w[relevance newest oldest]) || "relevance"
    options[:sort] = case @sort
    when "newest"
      [ "created_at:desc" ]
    when "oldest"
      [ "created_at:asc" ]
    end

    case @type
    when "posts"
      options[:filter] = "status = 'published'"
      posts = Post.published.pagy_search(params[:q], options)
      @pagy, @posts = pagy_meilisearch(posts)
    when "comments"
      comments = Comment.pagy_search(params[:q], options)
      @pagy, @comments = pagy_meilisearch(comments)
    when "accounts"
      accounts = Account.pagy_search(params[:q], options)
      @pagy, @accounts = pagy_meilisearch(accounts)
    end
  end

  private

  def search_params
    params.permit(:q, :type, :sort)
  end
end
