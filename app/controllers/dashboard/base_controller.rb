class Dashboard::BaseController < ApplicationController
  before_action :require_sign_in
  before_action :set_account
  before_action :require_account_member

  private

  def set_account
    @account = Account.find_by!(name: params[:account_name])
  end

  def require_account_member
    if @account.user?
      if @account.owner != Current.user
        redirect_to account_root_path(@account.name), alert: "You are not allowed to access this page."
      end
    else
      if !@account.owner.members.where(user: Current.user).exists?
        redirect_to account_root_path(@account.name), alert: "You are not allowed to access this page."
      end
    end
  end
end
