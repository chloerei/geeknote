class Admin::Settings::WeeklyDigestsController < Admin::Settings::BaseController
  def show
  end

  def update
    if @site.update site_params
      redirect_to admin_settings_weekly_digest_path, notice: I18n.t("flash.settings_updated_successful")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def site_params
    params.require(:site).permit(:weekly_digest_email_enabled, :weekly_digest_header_html, :weekly_digest_footer_html)
  end
end
