class AI::ModelsController < ApplicationController
  def index
    @ai_models = available_chat_models
  end

  def show
    @ai_model = RubyLLM.models.find(params[:id], params[:provider])
  end

  def refresh
    RubyLLM.models.refresh!
    redirect_to ai_models_path, notice: "AI::Models refreshed successfully"
  end
end
