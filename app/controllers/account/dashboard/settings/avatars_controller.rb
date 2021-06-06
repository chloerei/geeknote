class Account::Dashboard::Settings::AvatarsController < Account::Dashboard::Settings::BaseController
  def update
    @account.owner.update avatar_params
    render turbo_stream: turbo_stream.replace('avatar-form', partial: 'form')
  end

  private

  def avatar_params
    if @account.user?
      params.require(:user).permit(:avatar)
    else
      params.require(:organization).permit(:avatar)
    end
  end
end
