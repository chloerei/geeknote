class Account::Dashboard::Settings::BannerImagesController < Account::Dashboard::Settings::BaseController
  def update
    @account.owner.update avatar_params
    render turbo_stream: turbo_stream.replace('banner-image-form', partial: 'form')
  end

  def destroy
    @account.owner.banner_image.purge_later
    render turbo_stream: turbo_stream.replace('banner-image-form', partial: 'form')
  end

  private

  def avatar_params
    if @account.user?
      params.require(:user).permit(:banner_image)
    else
      params.require(:organization).permit(:banner_image)
    end
  end
end
