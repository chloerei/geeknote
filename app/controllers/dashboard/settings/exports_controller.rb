class Dashboard::Settings::ExportsController < Dashboard::Settings::BaseController
  def show
    @page_titles.prepend t("general.export")
  end

  def create
    if @account.export && @account.export.created_at > 1.day.ago
      redirect_to dashboard_settings_export_path(@account.name), alert: "You can only export once per day."
    else
      @account.create_export
      redirect_to dashboard_settings_export_path(@account.name), notice: "Export is being processed."
    end
  end
end
