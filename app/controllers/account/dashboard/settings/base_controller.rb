class Account::Dashboard::Settings::BaseController < Account::Dashboard::BaseController
  before_action do
    unless current_member.has_permission?(:edit_account_settings)
      render_not_found
    end
  end
end
