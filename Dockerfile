### base stage ###

FROM rubylang/ruby:3.1 AS base

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  libpq-dev \
  libvips42 \
  nodejs \
  npm \
  postgresql-client

RUN gem install bundler -v 2.3.6 && \
  bundle config set --global path vendor/bundle

WORKDIR /app

### CI stage ###

FROM base AS production

COPY Gemfile Gemfile.lock /app/

RUN bundle install

COPY package.json package-lock.json /app/

RUN npm install

COPY . /app/

RUN bin/rails assets:precompile
