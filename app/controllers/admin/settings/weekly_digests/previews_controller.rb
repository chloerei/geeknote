class Admin::Settings::WeeklyDigests::PreviewsController < Admin::Settings::BaseController
  def show
    @user = User.new email: Current.user.email
  end

  def create
    @user = User.find_by email: params[:user][:email]

    if @user
      UserMailer.with(user: @user).weekly_digest.deliver_later
      redirect_to admin_settings_weekly_digest_preview_path, notice: t(".success")
    else
      @user = User.new email: params[:user][:email]
      @user.errors.add :email, :not_exists
      render :show, status: :unprocessable_entity
    end
  end
end
