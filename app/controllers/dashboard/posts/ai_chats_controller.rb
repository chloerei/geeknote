class Dashboard::Posts::AIChatsController < Dashboard::Posts::BaseController
  before_action :set_ai_chat, only: [ :show, :destroy ]

  layout "application"

  def index
    @pagy, @ai_chats = pagy(@post.ai_chats.includes(:ai_messages).order(created_at: :desc))
    @ai_message = AI::Message.new

    @page_titles.prepend t(".index.title")
  end

  def show
    @pagy, @ai_messages = pagy(@ai_chat.ai_messages.reorder(id: :desc))
    @ai_message = AI::Message.new
    @page_titles.prepend t(".show.title")
  end

  def create
    content = params.dig(:ai_message, :content)
    if content.present?
      @ai_chat = @post.ai_chats.new(user: Current.user, snapshot: snapshot_params)

      if @ai_chat.save
        @ai_chat.ask_later(content)
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

  private

  def snapshot_params
    params.fetch(:snapshot, {}).permit(:title, :content)
  end

  def set_ai_chat
    @ai_chat = @post.ai_chats.find(params[:id])
  end
end
