class UsersController < ApplicationController
  def new
    @user = User.new
    @user.build_account
  end

  def create
    @user = User.new user_params

    if @user.save
      sign_in(@user)
      redirect_to root_url
    else
      render turbo_stream: turbo_stream.replace('sign-up-form', partial: 'form')
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, account_attributes: [:name])
  end
end
