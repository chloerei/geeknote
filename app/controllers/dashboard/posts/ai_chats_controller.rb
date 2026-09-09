class Dashboard::Posts::AIChatsController < Dashboard::Posts::BaseController
  before_action :set_ai_chat, only: [ :show, :destroy, :cancel ]

  layout "application"

  def index
    @pagy, @ai_chats = pagy(@post.ai_chats.order(created_at: :desc))
    @ai_message = AI::Message.new

    @page_titles.prepend t(".index.title")
  end

  def show
    # Tool results render inside their parent tool-call card, never as
    # standalone list entries.
    @pagy, @ai_messages = pagy(@ai_chat.ai_messages.without_tool_results.reorder(id: :desc))
    @ai_message = AI::Message.new
    @page_titles.prepend t(".show.title")
  end

  def create
    content = params.dig(:ai_message, :content)
    if content.present?
      @ai_chat = @post.ai_chats.new(user: Current.user, snapshot: snapshot_params)

      if @ai_chat.save
        # A new round starts here: clear any leftover cancellation request from
        # the previous round (and any parked edit) and mark this round as
        # processing.
        @ai_chat.ask_later(content)
        @ai_chat.update_columns(cancelled: false, processing: true, restart_from_message_id: nil)
        AIChatTitleJob.perform_later(@ai_chat)
        AIChatResponseJob.perform_later(@ai_chat)
        redirect_to dashboard_post_ai_chat_path(@account.name, @post, @ai_chat), notice: t(".success")
      else
        redirect_to dashboard_post_ai_chats_path(@account.name, @post), alert: t(".create_failed")
      end
    else
      head :no_content
    end
  end

  def destroy
    @ai_chat.destroy!
    redirect_to dashboard_post_ai_chats_path(@account.name, @post), notice: t(".success"), status: :see_other
  end

  # Stops the round currently being generated. cancel (from the ruby_llm gem)
  # persists the cancellation request to the cancelled column; the running
  # AIChatResponseJob notices it at its next checkpoint (polled every ~1s) and
  # aborts. Here we reset processing immediately and put the composer back into
  # its submittable state. An explicit stop also withdraws a parked edit
  # request: stopping wins over regenerating from the edit.
  def cancel
    @ai_chat.cancel
    @ai_chat.update_columns(processing: false, restart_from_message_id: nil)

    respond_to do |format|
      format.turbo_stream
      format.html do
        redirect_to dashboard_post_ai_chat_path(@account.name, @post, @ai_chat), notice: t(".success")
      end
    end
  end

  private

  def snapshot_params
    params.fetch(:snapshot, {}).permit(:title, :content)
  end

  def set_ai_chat
    @ai_chat = @post.ai_chats.find(params[:id])
  end
end
