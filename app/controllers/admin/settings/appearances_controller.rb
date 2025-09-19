class Admin::Settings::AppearancesController < Admin::Settings::BaseController
  def show
  end

  def update
    if @site.update site_params
      redirect_to admin_settings_appearance_path, notice: t(".success")
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def site_params
    params.require(:site).permit(:name, :description, :icon, :logo, :logo_dark, :remove_icon, :remove_logo, :remove_logo_dark, :site_header_html, :site_footer_html, :sidebar_header_html, :sidebar_footer_html, :global_head_html)
  end
end
