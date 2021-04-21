class Settings::OrganizationsController < Settings::BaseController
  def index
    @organizations = current_user.organizations.select("organizations.*, memberships.role as role").includes(:account)
  end
end
