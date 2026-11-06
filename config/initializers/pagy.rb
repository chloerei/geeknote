# frozen_string_literal: true

# Pagy initializer (43.x)
# See https://ddnexus.github.io/pagy/toolbox/configuration/initializer/

# Raise an error for out-of-range pages (pagy 9 did this by default). It is rescued as a 404
# in ApplicationController. Without this option pagy 43 serves an empty page instead.
Pagy::OPTIONS[:raise_range_error] = true

Pagy::OPTIONS.freeze

# Search paginators (`pagy(:meilisearch, ...)`) do not translate ActiveRecord scopes into
# Meilisearch filters, so filtering is done explicitly with the :filter option in
# SearchController.

# Pagy 43 makes #series protected because its own nav helpers (e.g. #series_nav) call it
# internally. The app renders its own pagination markup in
# app/views/components/_page_pagination.html.erb, so expose it publicly.
class Pagy
  def page_series(**) = series(**)
end
