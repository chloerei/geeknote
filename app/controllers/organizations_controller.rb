class OrganizationsController < ApplicationController
  def new
    @organization = Organization.new
    @organization.build_account
  end

  def create
    @organization = Organization.new organization_params

    if @organization.save
      redirect_to account_root_path(@organization.account)
    else
      render turbo_stream: turbo_stream.replace('organization-form', partial: 'form')
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :description, account_attributes: [:path])
  end
end
