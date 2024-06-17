class Identity::PasswordsController < ApplicationController
  before_action :set_user, only: [ :edit, :update ]

  def new
    @user = User.new
  end

  def create
    @user = User.find_or_initialize_by email: params[:user][:email]

    if optional_verify_recaptcha(model: @user) && @user.persisted?
      cache_key = "password_reset:#{@user.email}"
      if Rails.cache.exist?(cache_key)
        @user.errors.add :base, t("flash.password_reset_email_time_limit")
        render :new, status: :unprocessable_entity
      else
        UserMailer.with(user: @user).password_reset_email.deliver_later
        Rails.cache.write(cache_key, true, expires_in: 1.minute)
        redirect_to sign_in_path, notice: t("flash.password_reset_email_has_been_sent")
      end
    else
      if @user.new_record?
        @user.errors.add :email, :not_exists
      end

      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update user_params
      redirect_to sign_in_path, notice: "Password has been reset."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by_token_for!(:password_reset, params[:token])
  rescue StandardError
    redirect_to new_identity_password_path, notice: "Invalid token. Please try again."
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
