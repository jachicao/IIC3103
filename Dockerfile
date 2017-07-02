FROM ruby:slim

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN apt-get update -qq && apt-get install -y imagemagick
RUN apt-get update -qq && apt-get install -y unixodbc unixodbc-dev unixodbc-bin
RUN apt-get update -qq && apt-get install -y freetds-bin freetds-common freetds-dev

RUN mkdir /myapp
WORKDIR /myapp

ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN bundle install --jobs 20 --retry 5 --full-index
ADD . /myapp

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]