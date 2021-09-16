### base stage ###

FROM ubuntu:20.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  curl \
  git \
  gnupg \
  imagemagick \
  libpq-dev \
  nodejs \
  npm \
  postgresql-client \
  ruby \
  ruby-dev \
  zlib1g-dev

RUN gem install bundler -v 2.2.0

WORKDIR /app

### CI stage ###

FROM base AS ci

COPY Gemfile Gemfile.lock /app/

RUN bundle install --deployment

COPY package.json package-lock.json /app/

RUN npm install

COPY . /app/

### Budiler stage ###

FROM ci AS builder

RUN RAILS_ENV=production SECRET_KEY_BASE=1 bin/rails assets:precompile

### production stage ###

FROM base AS production

COPY Gemfile Gemfile.lock /app/

RUN bundle install --deployment --without test development && \
  rm vendor/bundle/ruby/2.7.0/cache/*

COPY . /app/

COPY --from=builder /app/public/assets /app/public/assets

ENV RAILS_ENV=production
