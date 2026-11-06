class TagsController < ApplicationController
  def show
    @tag = Tag.find_by! name: params[:id]
    @pagy, @posts = pagy(:offset, Post.published.tagged_with(params[:id]).order(published_at: :desc))
  end
end
