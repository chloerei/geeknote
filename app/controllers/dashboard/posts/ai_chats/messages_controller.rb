class Dashboard::Posts::AIChats::MessagesController < Dashboard::Posts::BaseController
  before_action :set_ai_chat

  def create
    content = params.dig(:ai_message, :content)
    if content.present?
      AIChatResponseJob.perform_later(@ai_chat.id, content)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to dashboard_post_ai_chat_path(@account.name, @post, @ai_chat) }
      end
    else
      head :no_content
    end
  end

  private

  def set_ai_chat
    @ai_chat = @post.ai_chats.find(params[:ai_chat_id])
  end
end
