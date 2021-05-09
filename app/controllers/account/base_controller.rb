class Account::BaseController < ApplicationController
  before_action :set_account

  private

  def set_account
    @account = Account.find_by! name: params[:account_name]
  end

  def require_organization_account
    unless @account.organization?
      render_not_found
    end
  end

  def require_user_account
    unless @account.user?
      render_not_found
    end
  end
end
