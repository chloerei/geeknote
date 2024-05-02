class Account::FollowsController < Account::BaseController
  before_action :require_sign_in

  def create
    @account.follows.find_or_create_by(user: current_user)
    render turbo_stream: turbo_stream.replace("account-#{@account.name}-follow-button", partial: "button", locals: { account: @account })
  end

  def destroy
    @account.follows.where(user: current_user).destroy_all
    render turbo_stream: turbo_stream.replace("account-#{@account.name}-follow-button", partial: "button", locals: { account: @account })
  end
end
