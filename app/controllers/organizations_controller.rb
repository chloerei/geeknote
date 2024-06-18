class OrganizationsController < ApplicationController
  before_action :require_sign_in

  def new
    @organization = Organization.new
    @organization.build_account
  end

  def create
    @organization = Organization.new organization_params

    if @organization.save
      @organization.members.create(role: "owner", user: current_user, status: :active)
      redirect_to dashboard_root_path(@organization.account.name)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name, account_attributes: [ :name ])
  end
end
