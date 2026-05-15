class OrganizationsController < ApplicationController
  before_action :require_authentication

  def index
    @organizations = Current.user.organizations
      .select("organizations.*, members.role AS member_role")
      .includes(:account)
      .order(created_at: :desc)
  end

  def new
    @organization = Organization.new
    @organization.build_account
  end

  def create
    @organization = Organization.new organization_params

    if @organization.save
      @organization.members.create(role: "admin", user: Current.user, status: :active)
      redirect_to dashboard_root_path(@organization.account.name)
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name, account_attributes: [ :name ])
  end
end
