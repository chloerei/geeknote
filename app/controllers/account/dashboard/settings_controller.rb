class Account::Dashboard::SettingsController < Account::Dashboard::BaseController
  before_action do
    unless current_member.has_permission?(:edit_account_settings)
      render_not_found
    end
  end

  def index
  end
end
