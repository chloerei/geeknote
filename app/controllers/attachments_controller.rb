class AttachmentsController < ApplicationController
  include ActiveStorage::SetCurrent

  before_action :require_sign_in, except: [:show]

  def create
    @attachment = Attachment.create attachment_params.merge(user: current_user)

    render json: {
      url: attachment_path(key: @attachment.key, filename: @attachment.file.filename.to_s)
    }
  end

  def show
    @attachment = Attachment.find_by! key: params[:key]
    expires_in ActiveStorage.service_urls_expire_in
    redirect_to @attachment.file.blob.url(disposition: params[:disposition]), allow_other_host: true
  end

  private

  def attachment_params
    params.require(:attachment).permit(:file)
  end
end
