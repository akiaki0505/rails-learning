# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

WORKDIR /rails_learning

ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# ===== build stage =====
FROM base as build

# build-essential などをインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      default-libmysqlclient-dev \
      git \
      libvips \
      pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .
#RUN bundle exec bootsnap precompile app/ lib/
#RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# ===== final stage =====
FROM base

# ここで apt-get update と install を同一RUNでまとめ、
# 最後に lists/* を削除してサイズを縮小
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      default-mysql-client \
      libvips \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails_learning /rails_learning

RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
#USER rails:rails

ENTRYPOINT ["/rails_learning/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["./bin/rails", "server"]
