class SessionsController < ApplicationController
  def new
    if params[:return_to]
      uri = URI(params[:return_to])
      session[:return_to] = [ uri.path, uri.query ].compact.join("?")
    end

    @user = User.new
  end

  def create
    @user = User.find_or_initialize_by(email: params[:user][:email])

    if optional_verify_recaptcha(model: @user)
      if @user.authenticate(params[:user][:password])
        sign_in(@user)
        redirect_to session.delete(:return_to) || root_path
      else
        @user.errors.add(:base, :email_or_password_error)
        render :new, status: :unprocessable_entity
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
