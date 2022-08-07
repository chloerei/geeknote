class User::PasswordsController < ApplicationController
  before_action :set_user, only: [:edit, :update]

  def new
  end

  def create
    user = User.find_by email: params[:email]

    if optional_verify_recaptcha() && user
      cache_key = "password_reset:#{user.email}"
      if Rails.cache.exist?(cache_key)
        redirect_to new_user_password_path, notice: t('flash.password_reset_email_time_limit')
      else
        UserMailer.with(user: user).password_reset_email.deliver_later
        Rails.cache.write(cache_key, true, expires_in: 1.minute)
        redirect_to sign_in_path, notice: t('flash.password_reset_email_has_been_sent')
      end
    else
      redirect_to new_user_password_path, notice: t('flash.password_reset_user_does_not_exists')
    end
  end

  def edit
  end

  def update
    if @user.update user_params
      redirect_to sign_in_path, notice: t('flash.password_reset_successful')
    else
      render turbo_stream: turbo_stream.replace('password-reset-form', partial: 'form')
    end
  end

  private

  def set_user
    @user = User.find_by_password_reset_token(params[:token])

    if @user.nil?
      redirect_to new_user_password_path, notice: t('flash.password_reset_token_invliad')
    end
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
