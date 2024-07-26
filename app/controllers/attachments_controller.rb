class AttachmentsController < ApplicationController
  include ActiveStorage::SetCurrent

  before_action :require_sign_in, except: [ :show ]

  def create
    attachment = Attachment.create attachment_params.merge(user: current_user)

    render json: {
      url: "/attachments/#{attachment.key}",
      filename: attachment.file.filename.to_s,
      content_type: attachment.file.content_type
    }
  end

  def show
    attachment = Attachment.find_by key: params[:key]

    if attachment
      expires_in ActiveStorage.service_urls_expire_in
      redirect_to attachment.file.url, allow_other_host: true
    else
      head :not_found
    end
  end

  private

  def attachment_params
    params.require(:attachment).permit(:file)
  end
end
