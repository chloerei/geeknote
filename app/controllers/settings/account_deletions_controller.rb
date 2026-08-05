class Settings::AccountDeletionsController < Settings::BaseController
  def show
    @page_titles.prepend t("general.delete_account")
  end

  def create
    if params[:name] == @user.account.name
      UserDeletionJob.perform_later(@user)
      terminate_session
      redirect_to account_deleted_path
    else
      flash.now[:alert] = t(".account_name_mismatch")
      render :show, status: :unprocessable_content
    end
  end
end
