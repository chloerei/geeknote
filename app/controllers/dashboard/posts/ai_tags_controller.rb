class Dashboard::Posts::AITagsController < Dashboard::BaseController
  # Suggests tags for the draft the editor submitted. The draft is read from the
  # request rather than from the database: it may hold unsaved changes, and the
  # route also serves the new post form, where no post exists yet.
  def create
    return head :service_unavailable unless AI::TagSuggestion.available?

    tags = AI::TagSuggestion.new(title: params[:title], content: params[:content]).call

    render json: { tags: tags }
  rescue RubyLLM::Error => e
    Rails.logger.error("AITagsController: tag suggestion failed: #{e.class}: #{e.message}")
    render json: { error: t(".failure") }, status: :bad_gateway
  end
end
