class Settings::BaseController < ApplicationController
  before_action :require_authentication
  before_action :set_user
  before_action :set_title

  private

  def set_user
    @user = Current.user
  end

  def set_title
    @page_titles.prepend t("general.settings")
  end
end
