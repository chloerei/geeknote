class Dashboard::Settings::ExportsController < Dashboard::Settings::BaseController
  def show
    @page_titles.prepend t("general.export")
  end

  def create
    if @account.export && @account.export.created_at > 1.day.ago
      redirect_to dashboard_settings_export_path(@account.name), alert: t(".rate_limit")
    else
      @account.create_export
      redirect_to dashboard_settings_export_path(@account.name), notice: t(".processing")
    end
  end
end
