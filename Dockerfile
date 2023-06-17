### base stage ###

FROM ruby:3.2.2 AS base

ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  chromium \
  fonts-noto-cjk \
  libpq-dev \
  libvips42 \
  postgresql-client

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
  apt-get install -y nodejs

RUN gem install bundler -v 2.4.14 && \
  bundle config set --local path vendor/bundle

RUN useradd -m rails && \
  mkdir /rails && \
  chown rails:rails /rails

USER rails:rails

WORKDIR /rails

### production stage ###

FROM base

ENV BUNDLE_FROZEN=true

COPY --chown=rails:rails Gemfile Gemfile.lock /rails/

RUN bundle install

COPY --chown=rails:rails package.json package-lock.json /rails/

RUN npm install

COPY --chown=rails:rails . /rails/

RUN bin/rails assets:precompile
