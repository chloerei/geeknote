class Account::Dashboard::AttachmentsController < Account::Dashboard::BaseController
  def create
    @attachment = @account.attachments.create attachment_params.merge(user: current_user)

    render json: {
      url: attachment_path(key: @attachment.key, filename: @attachment.file.filename.to_s)
    }
  end

  private

  def attachment_params
    params.require(:attachment).permit(:file)
  end
end
