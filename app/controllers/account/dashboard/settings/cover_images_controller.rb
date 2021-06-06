class Account::Dashboard::Settings::CoverImagesController < Account::Dashboard::Settings::BaseController
  def update
    @account.owner.update avatar_params
    render turbo_stream: turbo_stream.replace('cover-image-form', partial: 'form')
  end

  def destroy
    @account.owner.cover_image.purge_later
    render turbo_stream: turbo_stream.replace('cover-image-form', partial: 'form')
  end

  private

  def avatar_params
    if @account.user?
      params.require(:user).permit(:cover_image)
    else
      params.require(:organization).permit(:cover_image)
    end
  end
end
