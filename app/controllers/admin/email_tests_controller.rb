class Admin::EmailTestsController < Admin::ApplicationController
  def index
  end

  def create
    @user = User.find_by(email: params[:email_test][:email])
    if @user
      UserMailer.with(user: @user).weekly_digest.deliver_later
      redirect_to admin_email_tests_path, notice: "Email sent to #{@user.email}"
    else
      flash.now[:alert] = "User with email #{params[:email_test][:email]} not found."
      render :index, status: :unprocessable_entity
    end
  end
end
