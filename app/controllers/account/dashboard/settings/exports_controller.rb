class Account::Dashboard::Settings::ExportsController < Account::Dashboard::Settings::BaseController
  def index
    @exports = @account.exports.page(params[:page]).order(id: :desc)
  end

  def create
    if @account.exports.pending.any?
      redirect_to account_dashboard_settings_exports_path(@account), notice: t('flash.export_task_already_exists')
    else
      @export = @account.exports.create
      AccountExportJob.perform_later(@export)
      redirect_to account_dashboard_settings_exports_path(@account), notice: t('flash.export_task_processing')
    end
  end

  def destroy
    @export = @account.exports.find params[:id]
    @export.destroy
    render turbo_stream: turbo_stream.remove("export-#{@export.id}")
  end
end
