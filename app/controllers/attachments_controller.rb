class AttachmentsController < ActiveStorage::BaseController
  def show
    @blob = ActiveStorage::Blob.find_by! key: params[:key]
    expires_in ActiveStorage.service_urls_expire_in
    redirect_to @blob.url(disposition: params[:disposition])
  end
end
