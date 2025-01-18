class Suggest::TagsController < ApplicationController
  def index
    @tags = Tag.search(params[:q], limit: 5)
  end
end
