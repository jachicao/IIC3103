FROM ruby:alpine

ENV BUILD_PACKAGES="curl-dev ruby-dev build-base bash" \
    DEV_PACKAGES="zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev postgresql-dev" \
    RUBY_PACKAGES="ruby-json yaml nodejs imagemagick unixodbc freetds"

RUN apk update && \
    apk upgrade && \
    apk add --update\
    $BUILD_PACKAGES \
    $DEV_PACKAGES \
    $RUBY_PACKAGES && \
    rm -rf /var/cache/apk/*

RUN mkdir /myapp
WORKDIR /myapp
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN bundle install --jobs 20 --retry 5
ADD . /myapp

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]