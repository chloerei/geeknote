class UsersController < ApplicationController
  def new
    if params[:return_to]
      uri = URI(params[:return_to])
      session[:return_to] = [uri.path, uri.query].compact.join('?')
    end
    @user = User.new
    @user.build_account
  end

  def create
    @user = User.new user_params

    if optional_verify_recaptcha(model: @user) &&  @user.save
      sign_in(@user)
      UserMailer.with(user: @user).email_verification.deliver_later
      redirect_to session.delete(:return_to) || root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, account_attributes: [:name])
  end
end
