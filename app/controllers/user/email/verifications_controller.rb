class User::Email::VerificationsController < ApplicationController
  before_action :set_user

  def show
  end

  def update
    @user.email_verified!
    render turbo_stream: turbo_stream.replace(:main, partial: "success")
  end

  private

  def set_user
    @user = User.find_by_email_auth_token(params[:token])

    unless @user
      render :expired, status: :not_found
    end
  end
end
