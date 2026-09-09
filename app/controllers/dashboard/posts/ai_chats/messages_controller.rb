class Dashboard::Posts::AIChats::MessagesController < Dashboard::Posts::BaseController
  before_action :set_ai_chat

  def create
    content = params.dig(:ai_message, :content)
    return head :no_content if content.blank?

    @created = false
    # One live round per chat: refuse while generating unless a stop is pending
    # (the composer disables submit, but a second tab can still race in).
    @ai_chat.with_lock do
      @ai_chat.reload
      next if @ai_chat.processing? && !@ai_chat.cancelled?

      @ai_chat.update(snapshot: snapshot_params) if params[:snapshot].present?
      @ai_chat.ask_later(content)
      # The new round supersedes any leftover cancel request or parked edit.
      @ai_chat.update_columns(cancelled: false, processing: true, restart_from_message_id: nil)
      AIChatResponseJob.perform_later(@ai_chat)
      @created = true
    end

    head :no_content unless @created
  end

  # Swap the message row for the composer-based edit form.
  def edit
    @message = editable_message
  end

  # Abandon the edit and swap the row back to its bubble.
  def show
    @message = editable_message
  end

  # Saves an edited user message and restarts the conversation from it. While a
  # round is running (or draining after a stop) the restart is parked and
  # applied by the round's finish_round once its writes have settled.
  def update
    @message = editable_message

    content = params.dig(:ai_message, :content)
    # Blank content is ignored, like the composer's create.
    return head :no_content if content.blank?

    @ai_chat.update(snapshot: snapshot_params) if params[:snapshot].present?
    @message.update!(ai_message_params)

    @ai_chat.with_lock do
      @ai_chat.reload
      if @ai_chat.processing? || @ai_chat.cancelled?
        # Cancellation lags (polled): park the truncation for finish_round.
        @ai_chat.update_columns(restart_from_message_id: @message.id, processing: true)
        @ai_chat.cancel
      else
        @ai_chat.restart_from!(@message)
      end
    end
  end

  private

  # Only user messages are editable; RecordNotFound → 404 via ApplicationController.
  def editable_message
    @ai_chat.ai_messages.where(role: "user").find(params[:id])
  end

  def ai_message_params
    params.require(:ai_message).permit(:content)
  end

  def snapshot_params
    params.fetch(:snapshot, {}).permit(:title, :content)
  end

  def set_ai_chat
    @ai_chat = @post.ai_chats.find(params[:ai_chat_id])
  end
end
