class AI::MessagesController < ApplicationController
  before_action :set_ai_chat

  def create
    content = params.dig(:ai_message, :content)
    if content.present?
      AIChatResponseJob.perform_later(@ai_chat.id, content)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @ai_chat }
      end
    end
  end

  private

  def set_ai_chat
    @ai_chat = AI::Chat.find(params[:chat_id])
  end
end
