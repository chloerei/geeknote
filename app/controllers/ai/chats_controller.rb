class AI::ChatsController < ApplicationController
  before_action :set_ai_chat, only: [ :show, :destroy ]

  def index
    @ai_chats = AI::Chat.order(created_at: :desc)
  end

  def new
    @ai_chat = AI::Chat.new
    @selected_model = params[:provider] ? [params[:provider], params[:model]].join(":") : params[:model]
    @chat_models = available_chat_models
  end

  def create
    prompt = params.dig(:ai_chat, :prompt)
    if prompt.present?
      provider, model = params.dig(:ai_chat, :model).to_s.split(":", 2)
      @ai_chat = AI::Chat.create!(model: model.presence, provider: provider.presence)
      AIChatResponseJob.perform_later(@ai_chat.id, prompt)

      redirect_to @ai_chat, notice: "AI::chat was successfully created."
    end
  end

  def show
    @ai_message = AI::Message.new
  end

  def destroy
    @ai_chat.destroy!
    redirect_to ai_chats_path, notice: "AI::chat was successfully destroyed.", status: :see_other
  end

  private

  def set_ai_chat
    @ai_chat = AI::Chat.find(params[:id])
  end
end
