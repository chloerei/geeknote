require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    account: Field::HasOne,
    # avatar_attachment: Field::HasOne,
    # avatar_blob: Field::HasOne,
    # banner_image_attachment: Field::HasOne,
    # banner_image_blob: Field::HasOne,
    name: Field::String,
    bio: Field::Text,
    comment_email_notification_enabled: Field::Boolean,
    email: Field::String,
    email_notification_enabled: Field::Boolean,
    email_verified_at: Field::DateTime,
    followings_count: Field::Number,
    organizations: Field::HasMany,
    weekly_digest_email_enabled: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    name
    email
    created_at
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    account
    name
    bio
    email
    email_verified_at
    comment_email_notification_enabled
    email_notification_enabled
    organizations
    weekly_digest_email_enabled
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    account
    name
    bio
    email
    email_verified_at
    comment_email_notification_enabled
    email_notification_enabled
    weekly_digest_email_enabled
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(user)
  #   "User ##{user.id}"
  # end
end
