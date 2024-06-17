class Identity::Email::VerificationsController < ApplicationController
  before_action :set_user

  def show
  end

  def update
    @user.email_verified!
    redirect_to root_path, notice: "Email verified!"
  end

  private

  def set_user
    @user = User.find_by_email_auth_token(params[:token])

    unless @user
      render :expired, status: :not_found
    end
  end
end
