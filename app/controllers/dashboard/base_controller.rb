class Dashboard::BaseController < ApplicationController
  before_action :require_authentication
  before_action :set_account
  before_action :set_title
  before_action :require_account_member

  layout "dashboard"

  private

  def set_account
    @account = Account.find_by!(name: params[:account_name])
  end

  def set_title
    @page_titles.prepend t("general.dashboard")
    @page_titles.prepend @account.name
  end

  def require_account_member
    if @account.user?
      if @account.owner != Current.user
        redirect_to account_root_path(@account.name), alert: "You are not allowed to access this page."
      end
    else
      @member = @account.owner.members.find_by(user: Current.user)
      if !@member
        redirect_to account_root_path(@account.name), alert: "You are not allowed to access this page."
      end
    end
  end
end
