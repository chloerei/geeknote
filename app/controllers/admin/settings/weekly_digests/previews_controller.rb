class Admin::Settings::WeeklyDigests::PreviewsController < Admin::Settings::BaseController
  def show
    @user = User.new email: current_user.email
  end

  def create
    @user = User.find_by email: params[:user][:email]

    if @user
      UserMailer.with(user: @user).weekly_digest.deliver_later
      redirect_to admin_settings_weekly_digest_preview_path, notice: I18n.t("flash.weekly_digest_preview_sent_successful")
    else
      @user = User.new email: params[:user][:email]
      @user.errors.add :email, :not_exists
      render :show, status: :unprocessable_entity
    end
  end
end
