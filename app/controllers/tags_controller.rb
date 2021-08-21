class TagsController < ApplicationController
  def show
    @posts = Post.published.tagged_with(params[:id]).page(params[:page])
  end

  def search
    @tags = Tag.search(params[:q]).order(taggings_count: :desc).limit(5)
  end
end
