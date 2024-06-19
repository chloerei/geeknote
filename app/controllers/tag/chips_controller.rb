class Tag::ChipsController < ApplicationController
  def create
    @tags = params[:combobox_values].split(",").map do |name|
      Tag.find_or_initialize_by(name: name.strip)
    end
    render turbo_stream: helpers.combobox_selection_chips_for(@tags, display: :name, value: :name)
  end
end
