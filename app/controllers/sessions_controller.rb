class SessionsController < ApplicationController
  layout "application"

  def new
    @user = User.new
  end

  def create
    @user = User.find_or_initialize_by(email: params[:user][:email])

    if optional_verify_recaptcha(model: @user)
      if @user.authenticate(params[:user][:password])
        start_new_session_for @user
        redirect_to after_authentication_url
      else
        @user.errors.add(:password, :email_or_password_error)
        render :new, status: :unprocessable_entity
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to root_url
  end
end
