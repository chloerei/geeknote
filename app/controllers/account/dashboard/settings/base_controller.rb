class Account::Dashboard::Settings::BaseController < Account::Dashboard::BaseController
  before_action do
    unless current_member.role.in?(%w(owner admin))
      render_not_found
    end
  end
end
