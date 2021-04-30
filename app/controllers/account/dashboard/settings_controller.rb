class Account::Dashboard::SettingsController < Account::Dashboard::BaseController
  before_action :require_account_admin

  def show
  end
end
