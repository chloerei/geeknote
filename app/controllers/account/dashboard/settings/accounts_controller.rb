class Account::Dashboard::Settings::AccountsController < Account::Dashboard::Settings::BaseController
  def show
  end

  def update
    if @account.update account_params
      redirect_to account_dashboard_settings_account_path(@account), notice: I18n.t('flash.account_updated')
    else
      render turbo_stream: turbo_stream.replace('account-form', partial: 'form')
    end
  end

  private

  def account_params
    params.require(:account).permit(:name)
  end
end
