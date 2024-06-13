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

  private

  def attachment_params
    params.require(:attachment).permit(:file)
  end
end
