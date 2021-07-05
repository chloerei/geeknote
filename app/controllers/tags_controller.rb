class TagsController < ApplicationController
  def show
    @posts = Post.published.with_statuses(current_user).tagged_with(params[:id]).page(params[:page])
  end

  def search
    @tags = Tag.search(params[:q]).order(taggings_count: :desc).limit(5)
  end
end
