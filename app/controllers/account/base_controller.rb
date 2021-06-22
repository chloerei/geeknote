class Account::BaseController < ApplicationController
  before_action :set_account

  helper_method :current_member

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

  def current_member
    @current_member ||= if @account.user?
      if @account.owner == current_user
        Member.new(user: current_user, role: :owner)
      end
    else
      @account.owner.members.find_by(user: current_user)
    end
  end
end
