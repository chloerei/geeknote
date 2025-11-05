require "administrate/base_dashboard"

class SiteDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    description: Field::String,
    global_head_html: Field::Text,
    # icon_attachment: Field::HasOne,
    # icon_blob: Field::HasOne,
    # logo_attachment: Field::HasOne,
    # logo_blob: Field::HasOne,
    # logo_dark_attachment: Field::HasOne,
    # logo_dark_blob: Field::HasOne,
    name: Field::String,
    sidebar_footer_html: Field::Text,
    sidebar_header_html: Field::Text,
    site_footer_html: Field::Text,
    site_header_html: Field::Text,
    weekly_digest_email_enabled: Field::Boolean,
    weekly_digest_footer_html: Field::Text,
    weekly_digest_header_html: Field::Text,
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
    description
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    description
    global_head_html
    name
    sidebar_footer_html
    sidebar_header_html
    site_footer_html
    site_header_html
    weekly_digest_email_enabled
    weekly_digest_footer_html
    weekly_digest_header_html
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    description
    name
    global_head_html
    sidebar_footer_html
    sidebar_header_html
    site_footer_html
    site_header_html
    weekly_digest_email_enabled
    weekly_digest_footer_html
    weekly_digest_header_html
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

  # Overwrite this method to customize how sites are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(site)
  #   "Site ##{site.id}"
  # end
end
