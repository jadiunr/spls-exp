FROM ruby:2.5.1-alpine3.7

ENV LANG C.UTF-8

RUN apk --update add \
    build-base \
    mariadb-dev \
    tzdata \
    vim && \
    rm /usr/lib/libmysqld* && \
    rm /usr/bin/mysql* && \
    rm -rf /tmp/* /var/cache/apk/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install -j4 --path vendor/bundle
COPY . .

CMD bundle exec rails s -b 0.0.0.0