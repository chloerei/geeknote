class Suggest::TagsController < ApplicationController
  def index
    @tags = Tag.search(params[:query], limit: 5)
  end
end
