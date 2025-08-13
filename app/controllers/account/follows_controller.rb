class Account::FollowsController < Account::BaseController
  before_action :require_authentication

  def create
    @account.follows.find_or_create_by(user: Current.user)
    render turbo_stream: turbo_stream.replace("account-#{@account.name}-follow-button", partial: "button", locals: { account: @account })
  end

  def destroy
    @account.follows.where(user: Current.user).destroy_all
    render turbo_stream: turbo_stream.replace("account-#{@account.name}-follow-button", partial: "button", locals: { account: @account })
  end
end
