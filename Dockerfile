### base stage ###

FROM ruby:3.1.2 AS base

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  chromium \
  fonts-noto-cjk \
  libpq-dev \
  libvips42 \
  nodejs \
  npm \
  postgresql-client

ENV LANG=zh_CN.UTF-8

RUN gem install bundler -v 2.3.6 && \
  bundle config set --local path vendor/bundle

RUN useradd -m deploy && \
  mkdir /app && \
  chown deploy:deploy /app

USER deploy

WORKDIR /app

### CI stage ###

FROM base AS production

COPY --chown=deploy:deploy Gemfile Gemfile.lock /app/

RUN bundle install

COPY --chown=deploy:deploy package.json package-lock.json /app/

RUN npm install

COPY --chown=deploy:deploy . /app/

RUN bin/rails assets:precompile
