class RegistrationsController < ApplicationController
  layout "application"

  def new
    @user = User.new account_attributes: { name: params[:account_name] }
  end

  def create
    @user = User.new user_params

    if optional_verify_recaptcha(model: @user) && @user.save
      start_new_session_for(@user)
      UserMailer.with(user: @user).email_verification.deliver_later
      redirect_to after_authentication_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, account_attributes: [ :name ])
  end
end
