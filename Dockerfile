### base stage ###

FROM ruby:3.2.1 AS base

ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  chromium \
  fonts-noto-cjk \
  libpq-dev \
  libvips42 \
  nodejs \
  npm \
  postgresql-client

RUN gem install bundler && \
  bundle config set --local path vendor/bundle

RUN useradd -m rails && \
  mkdir /rails && \
  chown rails:rails /rails

USER rails:rails

WORKDIR /rails

### production stage ###

FROM base

COPY --chown=rails:rails Gemfile Gemfile.lock /rails/

RUN bundle install

COPY --chown=rails:rails package.json package-lock.json /app/

RUN npm install

COPY --chown=rails:rails . /app/

RUN bin/rails assets:precompile
