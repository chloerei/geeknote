class TagsController < ApplicationController
  def show
    @tag = Tag.find_by! name: params[:id]
    @posts = Post.published.tagged_with(params[:id]).page(params[:page])

    respond_to do |format|
      format.html { render 'home/index' }
    end
  end
end
