class Account::BaseController < ApplicationController
  before_action :set_account

  private

  def set_account
    @account = Account.find_by! path: params[:account_path]
  end
end
