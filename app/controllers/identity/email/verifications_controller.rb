class Identity::Email::VerificationsController < ApplicationController
  before_action :set_user
  layout "application"

  def show
  end

  def update
    @user.email_verified!
    redirect_to root_path, notice: "Email verified!"
  end

  private

  def set_user
    @user = User.find_by_token_for!(:email_verification, params[:token])
  rescue StandardError
    render :invalid, status: :not_found
  end
end
