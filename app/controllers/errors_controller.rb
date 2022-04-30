class ErrorsController < ApplicationController
  layout 'base'

  def not_found
    render_not_found
  end
end
