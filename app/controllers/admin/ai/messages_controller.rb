module Admin
  module AI
    class MessagesController < Admin::ApplicationController
      def destroy
        message = requested_resource
        chat = message.ai_chat

        # A message mid-stream is not worth the race: ask the running round to
        # stop before removing its rows.
        chat.cancel if chat.processing? || chat.cancelled?

        # A parked edit may point at this message (restart_from_message_id);
        # clear it so the foreign key does not block the delete.
        if chat.restart_from_message_id == message.id
          chat.update_column(:restart_from_message_id, nil)
        end

        message.destroy!
        flash[:notice] = t(".success")
        redirect_to after_resource_destroyed_path(message), status: :see_other
      end
    end
  end
end
