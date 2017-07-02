FROM ruby:latest

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN apt-get update -qq && apt-get install -y imagemagick
RUN apt-get update -qq && apt-get install -y unixodbc unixodbc-dev unixodbc-bin
RUN apt-get update -qq && apt-get install -y wget
#RUN apt-get update -qq && apt-get install -y freetds-bin freetds-common freetds-dev

ENV FREE_TDS_VERSION freetds-1.00.27

RUN wget https://github.com/jachicao/IIC3103_NodeJS/raw/master/${FREE_TDS_VERSION}.tar.gz && \
    tar -xzf ${FREE_TDS_VERSION}.tar.gz && \
    cd ${FREE_TDS_VERSION} && \
    ./configure --prefix=/usr/local --with-tdsver=7.3 && \
    make && \
    make install

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