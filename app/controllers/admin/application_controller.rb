# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    include Authentication

    before_action :require_authentication
    before_action :authenticate_admin

    private

    def authenticate_admin
      unless Current.user&.admin?
        render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
      end
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end

    def default_sorting_attribute
      :id
    end

    def default_sorting_direction
      :desc
    end
  end
end
