class TagsController < ApplicationController
  def show
    @posts = Post.published.tagged_with(params[:id]).page(params[:page])

    respond_to do |format|
      format.html
    end
  end
end
