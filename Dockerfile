FROM ruby:slim

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN apt-get update -qq && apt-get install -y imagemagick
RUN apt-get update -qq && apt-get install -y unixodbc unixodbc-dev unixodbc-bin
#RUN apt-get update -qq && apt-get install -y freetds-bin freetds-common freetds-dev

RUN wget ftp://ftp.freetds.org/pub/freetds/stable/freetds-1.00.47.tar.gz
RUN tar -xzf freetds-1.00.47.tar.gz
RUN cd freetds-1.00.47
RUN ./configure --prefix=/usr/local
RUN make
RUN make install

RUN mkdir /myapp
WORKDIR /myapp

RUN gem install i18n
RUN gem install tiny_tds
RUN gem install ruby-odbc

ADD Gemfile /myapp/Gemfile
#ADD Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
ADD . /myapp

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]