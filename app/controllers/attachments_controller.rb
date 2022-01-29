class AttachmentsController < ActiveStorage::BaseController
  def show
    @attachment = Attachment.find_by! key: params[:key]
    expires_in ActiveStorage.service_urls_expire_in
    redirect_to @attachment.file.blob.url(disposition: params[:disposition]), allow_other_host: true
  end
end
