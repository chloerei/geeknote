class Account::Dashboard::SettingsController < Account::Dashboard::BaseController
  before_action do
    unless current_member.role.in?(%w[owner admin])
      render_not_found
    end
  end

  def index
  end
end
