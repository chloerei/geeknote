class TagsController < ApplicationController
  def show
    @tag = Tag.find_by! name: params[:id]
    @posts = Post.published.tagged_with(params[:id]).order(published_at: :desc).page(params[:page])
    @paginator = RailsCursorPagination::Paginator.new(Post.published.tagged_with(params[:id]), order_by: :published_at, order: :desc, after: params[:after]).fetch
  end
end
