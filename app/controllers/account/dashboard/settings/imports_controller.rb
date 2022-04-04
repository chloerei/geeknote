class Account::Dashboard::Settings::ImportsController < Account::Dashboard::Settings::BaseController
  def show
  end

  def update
    if @account.update account_params
      if @account.feed_url.present?
        FeedImportJob.perform_later(@account)
      end

      redirect_to account_dashboard_settings_import_path(@account), notice: I18n.t('flash.import_settings_updated')
    else
      render turbo_stream: turbo_stream.replace('settings-form', partial: 'form')
    end
  end

  private

  def account_params
    params.require(:account).permit(:feed_url, :feed_mark_canonical)
  end
end
