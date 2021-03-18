class SessionsController < ApplicationController
  def new
    if params[:return_to]
      session[:return_to] = URI(params[:return_to]).path
    end
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      sign_in(user)
      redirect_to session.delete(:return_to) || root_path
    else
      @sign_in_error = true
      render turbo_stream: turbo_stream.replace('sign-in-form', partial: 'form')
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
