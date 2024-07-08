class Dashboard::Settings::ImportsController < Dashboard::Settings::BaseController
  def show
  end

  def update
    if @account.update account_params
      if @account.feed_url.present?
        FeedImportJob.perform_later(@account)
      end

      redirect_to dashboard_settings_import_path(@account.name), notice: t(".success")
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:account).permit(:feed_url, :feed_mark_canonical)
  end
end
