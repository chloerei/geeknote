class Admin::Settings::AppearancesController < Admin::Settings::BaseController
  def show
  end

  def update
    if @site.update site_params
      redirect_to admin_settings_appearance_path, notice: I18n.t('flash.appearance_update_successful')
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def site_params
    params.require(:site).permit(:name, :description)
  end
end
