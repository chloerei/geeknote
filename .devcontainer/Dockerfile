FROM ruby:4.0.0

# Default value to allow debug server to serve content over GitHub Codespace's port forwarding service
# The value is a comma-separated list of allowed domains
ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
      curl \
      libpq-dev \
      libvips42 \
      postgresql-client \
      git \
      nodejs \
      npm

WORKDIR /rails
