class ErrorsController < ApplicationController
  layout 'base'

  def not_found
    render '404', status: 404
  end
end
