class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @pagy, @users = pagy(User.order(id: :desc))
  end

  def show
  end

  def edit
  end

  def update
    if @user.update user_params
      redirect_to admin_user_path(@user), notice: "User updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "User deleted."
  end

  private

  def set_user
    @user = User.find params[:id]
  end

  def user_params
    params.require(:user).permit(:name, :email, :bio, :email_notification_enabled, :comment_email_notification_enabled, :weekly_digest_email_enabled)
  end
end
