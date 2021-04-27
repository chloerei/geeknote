class Account::Dashboard::Settings::BaseController < Account::Dashboard::BaseController
  before_action :require_account_admin
end
