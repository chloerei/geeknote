class Tag::OptionsController < ApplicationController
  def index
    @tags = Tag.where("name LIKE ?", "%#{params[:q]}%").order(taggings_count: :desc).limit(10)
    render turbo_stream: helpers.async_combobox_options(@tags, display: :name, value: :name)
  end
end
