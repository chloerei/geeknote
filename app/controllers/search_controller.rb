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
      # Explicit Meilisearch filter: ActiveRecord scopes are not translated by the paginator.
      options[:filter] = "status = 'published'"
      posts = Post.pagy_search(params[:q], **options)
      @pagy, @posts = pagy(:meilisearch, posts)
    when "comments"
      comments = Comment.pagy_search(params[:q], **options)
      @pagy, @comments = pagy(:meilisearch, comments)
    when "accounts"
      accounts = Account.pagy_search(params[:q], **options)
      @pagy, @accounts = pagy(:meilisearch, accounts)
    end

    @page_titles.prepend t("general.search")
  end

  private

  def search_params
    params.permit(:q, :type, :sort)
  end
end
