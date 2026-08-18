class Dashboard::Posts::AIChatsController < Dashboard::Posts::BaseController
  before_action :set_ai_chat, only: [ :show, :destroy ]

  def index
    @ai_chats = @post.ai_chats.includes(:ai_messages).order(created_at: :desc)
    @ai_chat = @post.ai_chats.new(user: Current.user)

    @page_titles.prepend t(".index.title")
  end

  def show
    @ai_message = AI::Message.new
    @page_titles.prepend t(".show.title")
  end

  def create
    prompt = params.dig(:ai_chat, :prompt)
    if prompt.present?
      @ai_chat = @post.ai_chats.new(user: Current.user)

      if @ai_chat.save
        AIChatResponseJob.perform_later(@ai_chat.id, prompt)
        redirect_to dashboard_post_ai_chat_path(@account.name, @post, @ai_chat), notice: t(".success")
      else
        redirect_to dashboard_post_ai_chats_path(@account.name, @post), alert: t(".create_failed")
      end
    else
      redirect_to dashboard_post_ai_chats_path(@account.name, @post), alert: t(".prompt_required")
    end
  rescue RubyLLM::ModelNotFoundError
    redirect_to dashboard_post_ai_chats_path(@account.name, @post), alert: t(".model_not_found")
  end

  def destroy
    @ai_chat.destroy!
    redirect_to dashboard_post_ai_chats_path(@account.name, @post), notice: t(".success"), status: :see_other
  end

  private

  def set_ai_chat
    @ai_chat = @post.ai_chats.find(params[:id])
  end
end
