class TagsController < ApplicationController
  def index
    @tags = Tag.trending.limit(25)
  end

  def show
    @tag = Tag.find_by! name: params[:id]
    @posts = Post.published.tagged_with(params[:id]).page(params[:page])

    respond_to do |format|
      format.html
    end
  end
end
