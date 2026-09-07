class Dashboard::Posts::AIChats::MessagesController < Dashboard::Posts::BaseController
  before_action :set_ai_chat

  def create
    content = params.dig(:ai_message, :content)
    if content.present?
      @ai_chat.update(snapshot: snapshot_params) if params[:snapshot].present?
      @ai_chat.ask_later(content)
      # A new round starts here: clear any leftover cancellation request and
      # mark the round as processing so the composer shows the stop button
      # (instead of submit) until the job finishes.
      @ai_chat.update_columns(cancelled: false, processing: true)
      AIChatResponseJob.perform_later(@ai_chat)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to dashboard_post_ai_chat_path(@account.name, @post, @ai_chat) }
      end
    else
      head :no_content
    end
  end

  private

  def snapshot_params
    params.fetch(:snapshot, {}).permit(:title, :content)
  end

  def set_ai_chat
    @ai_chat = @post.ai_chats.find(params[:ai_chat_id])
  end
end
