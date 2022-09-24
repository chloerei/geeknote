class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:edit, :update]

  def index
    @users = User.order(id: :desc).page(params[:page])

    if params[:email]
      @users = @users.where(email: params[:email])
    end
  end

  def edit
  end

  def update
    if @user.update user_params
      redirect_to edit_admin_user_path(@user), notice: 'User updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find params[:id]
  end

  def user_params
    params.require(:user).permit(:name, :email, :bio, :email_notification_enabled, :comment_email_notification_enabled, :weekly_digest_email_enabled)
  end
end
