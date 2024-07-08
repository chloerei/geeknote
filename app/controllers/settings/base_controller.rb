class Settings::BaseController < ApplicationController
  before_action :require_sign_in
  before_action :set_user

  private

  def set_user
    @user = Current.user
  end
end
