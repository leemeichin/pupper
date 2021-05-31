FROM ruby:2.4-alpine3.11

RUN apk add --no-cache --update --upgrade --virtual .railsdeps \
  build-base git \
  bzip2-dev libgcrypt-dev libxml2-dev libxslt-dev libressl-dev postgresql-dev sqlite-dev zlib-dev \
  ca-certificates nodejs tzdata libev-dev linux-headers yarn
RUN gem install bundler -v 1.14.3
RUN rm -rf /var/cache/apk/*

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app
RUN bundle install

#RUN bundle exec rspec
