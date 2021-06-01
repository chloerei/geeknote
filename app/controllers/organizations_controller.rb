class OrganizationsController < ApplicationController
  before_action :require_sign_in

  def index
    @memberships = current_user.memberships.includes(organization: :account)
  end

  def new
    @organization = Organization.new
    @organization.build_account
  end

  def create
    @organization = Organization.new organization_params

    if @organization.save
      @organization.memberships.create(role: 'owner', user: current_user, status: :active)
      redirect_to account_root_path(@organization.account)
    else
      render turbo_stream: turbo_stream.replace('organization-form', partial: 'form')
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :description, account_attributes: [:name])
  end
end
