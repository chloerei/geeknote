class TagsController < ApplicationController
  def search
    @tags = Tag.search(params[:q]).order(taggings_count: :desc).limit(5)
  end
end
