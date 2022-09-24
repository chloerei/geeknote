class Admin::OrganizationsController < Admin::BaseController
  before_action :set_organization, only: [:show, :edit, :update]

  def index
    @organizations = Organization.order(id: :desc).page(params[:page])

    if params[:email]
      @organizations = @organizations.where(email: params[:email])
    end
  end

  def show
  end

  def edit
  end

  def update
    if @organization.update organization_params
      redirect_to admin_organization_path(@organization), notice: 'Organization updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_organization
    @organization = Organization.find params[:id]
  end

  def organization_params
    params.require(:organization).permit(:name, :description)
  end
end
