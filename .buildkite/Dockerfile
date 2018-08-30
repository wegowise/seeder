FROM ruby:2.5
ENV REFRESHED_AT=2018-08-22

RUN mkdir /app
WORKDIR /app

ADD Gemfile seeder.gemspec /app/
ADD lib/seeder/version.rb /app/lib/seeder/
RUN bundle install

RUN curl https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh > /usr/local/bin/wait-for-it.sh \
    && chmod +x /usr/local/bin/wait-for-it.sh

ADD . /app
