class Admin::Settings::WeeklySummariesController < Admin::Settings::BaseController
  def show
  end

  def update
    if @site.update site_params
      redirect_to admin_settings_weekly_summary_path, notice: I18n.t('flash.settings_update_successful')
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def site_params
    params.require(:site).permit(:weekly_summary_email_enabled, :weekly_summary_header_html, :weekly_summary_footer_html)
  end
end
