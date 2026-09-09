require "administrate/base_dashboard"

module AI
  class MessageDashboard < Administrate::BaseDashboard
    # ATTRIBUTE_TYPES
    # a hash that describes the type of each of the model's fields.
    #
    # Each different type represents an Administrate::Field object,
    # which determines how the attribute is displayed
    # on pages throughout the dashboard.
    #
    # Messages are read-only for admins: raw provider payloads (`raw_content`,
    # `raw_reasoning`, `citations`, tool calls...) are intentionally not
    # exposed as fields.
    ATTRIBUTE_TYPES = {
      id: Administrate::Field::Number,
      ai_chat: Administrate::Field::BelongsTo,
      role: Administrate::Field::String,
      content: Administrate::Field::Text,
      thinking_text: Administrate::Field::Text,
      finish_reason: Administrate::Field::String,
      created_at: Administrate::Field::DateTime,
      updated_at: Administrate::Field::DateTime
    }.freeze

    # COLLECTION_ATTRIBUTES
    # an array of attributes that will be displayed on the model's index page.
    COLLECTION_ATTRIBUTES = %i[
      id
      ai_chat
      role
      content
    ].freeze

    # SHOW_PAGE_ATTRIBUTES
    # an array of attributes that will be displayed on the model's show page.
    SHOW_PAGE_ATTRIBUTES = %i[
      id
      ai_chat
      role
      content
      thinking_text
      finish_reason
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

    # Overwrite this method to customize how messages are displayed
    # across all pages of the admin dashboard.
    def display_resource(message)
      "#{message.role.presence || "message"} ##{message.id}"
    end
  end
end
