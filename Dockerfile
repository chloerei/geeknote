### base stage ###

FROM rubylang/ruby:3.1 AS base

RUN apt-get update && apt-get install -y --no-install-recommends \
  libpq-dev \
  libvips42 \
  nodejs \
  npm \
  postgresql-client

RUN gem install bundler -v 2.3.6

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
  rm vendor/bundle/ruby/3.1.0/cache/*

COPY . /app/

COPY --from=builder /app/public/assets /app/public/assets

ENV RAILS_ENV=production
