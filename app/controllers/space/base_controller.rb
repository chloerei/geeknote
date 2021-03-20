class Space::BaseController < ApplicationController
  before_action :set_space

  private

  def set_space
    @space = Space.find_by! path: params[:space_path]
  end
end
