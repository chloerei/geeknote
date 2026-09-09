module Admin
  module AI
    class ChatsController < Admin::ApplicationController
      # Deleting a chat cascades to every message (acts_as_chat declares the
      # association with dependent: :destroy). If a round is still generating
      # we first request a stop so the background job aborts at its next
      # checkpoint instead of writing rows under a deleted chat.
      def destroy
        chat = requested_resource
        chat.cancel if chat.processing? || chat.cancelled?

        chat.destroy!
        flash[:notice] = t(".success")
        redirect_to after_resource_destroyed_path(chat), status: :see_other
      end
    end
  end
end
