require "administrate/base_dashboard"

module AI
  class ChatDashboard < Administrate::BaseDashboard
    # ATTRIBUTE_TYPES
    # a hash that describes the type of each of the model's fields.
    #
    # Each different type represents an Administrate::Field object,
    # which determines how the attribute is displayed
    # on pages throughout the dashboard.
    #
    # A chat is read-only for admins: `snapshot`, `restart_from_message` and
    # the raw `ruby_llm_model_id` are intentionally not exposed as fields.
    ATTRIBUTE_TYPES = {
      id: Administrate::Field::Number,
      title: Administrate::Field::String,
      user: Administrate::Field::BelongsTo,
      post: Administrate::Field::BelongsTo,
      processing: Administrate::Field::Boolean,
      cancelled: Administrate::Field::Boolean,
      ai_messages: Administrate::Field::HasMany,
      created_at: Administrate::Field::DateTime,
      updated_at: Administrate::Field::DateTime
    }.freeze

    # COLLECTION_ATTRIBUTES
    # an array of attributes that will be displayed on the model's index page.
    COLLECTION_ATTRIBUTES = %i[
      id
      title
      user
      post
      ai_messages
    ].freeze

    SHOW_PAGE_ATTRIBUTES = %i[
      id
      title
      user
      post
      processing
      cancelled
      ai_messages
      created_at
      updated_at
    ].freeze

    # FORM_ATTRIBUTES
    # an array of attributes that will be displayed
    # on the model's form (`new` and `edit`) pages.
    FORM_ATTRIBUTES = [].freeze

    # COLLECTION_FILTERS
    # a hash that defines filters that can be used while searching via the
    # search field of the dashboard.
    COLLECTION_FILTERS = {}.freeze

    # Overwrite this method to customize how chats are displayed
    # across all pages of the admin dashboard.
    def display_resource(chat)
      chat.title.presence || "#{chat.class.model_name.human} ##{chat.id}"
    end
  end
end
