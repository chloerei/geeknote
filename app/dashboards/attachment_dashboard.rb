require "administrate/base_dashboard"

class AttachmentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    account: Field::BelongsTo,
    user: Field::BelongsTo,
    key: Field::String,
    file: ActiveStorageField,
    filename: Field::String.with_options(
      getter: ->(field) {
        field.resource.file.filename.to_s if field.resource.file.attached?
      }
    ),
    file_size: Field::String.with_options(
      getter: ->(field) {
        ActiveSupport::NumberHelper.number_to_human_size(field.resource.file.byte_size) if field.resource.file.attached?
      }
    ),
    content_type: Field::String.with_options(
      getter: ->(field) {
        field.resource.file.content_type if field.resource.file.attached?
      }
    ),
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
    key
    filename
    file_size
    content_type
    user
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    user
    key
    file
    file_size
    content_type
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    file
    user
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

  # Overwrite this method to customize how attachments are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(attachment)
  #   "Attachment ##{attachment.id}"
  # end
end
