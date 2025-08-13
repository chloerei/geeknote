class Account::BaseController < ApplicationController
  before_action :set_account
  before_action :set_title

  helper_method :current_member

  private

  def set_account
    @account = Account.find_by! name: params[:account_name]
  end

  def set_title
    @page_titles.prepend @account.owner.name
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
      if @account.owner == Current.user
        Member.new(user: Current.user, role: :owner)
      end
    else
      @account.owner.members.find_by(user: Current.user)
    end
  end
end
