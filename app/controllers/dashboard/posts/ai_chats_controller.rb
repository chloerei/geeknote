class Dashboard::Posts::AIChatsController < Dashboard::Posts::BaseController
  before_action :set_ai_chat, only: [ :show, :destroy ]

  def index
    @ai_chats = @post.ai_chats.includes(:model, :ai_messages).order(created_at: :desc)
    @ai_chat = @post.ai_chats.new(user: Current.user)
    @chat_models = available_chat_models
    @selected_model = params[:provider] ? [ params[:provider], params[:model] ].join(":") : params[:model]

    @page_titles.prepend t(".index.title")
  end

  def show
    @ai_message = AI::Message.new
    @page_titles.prepend t(".show.title")
  end

  def create
    prompt = params.dig(:ai_chat, :prompt)
    if prompt.present?
      provider, model = params.dig(:ai_chat, :model).to_s.split(":", 2)
      @ai_chat = @post.ai_chats.new(user: Current.user, model: model.presence, provider: provider.presence)

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
