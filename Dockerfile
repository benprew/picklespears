FROM ruby:2.6
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client
RUN mkdir /teamvite
WORKDIR /teamvite
COPY Gemfile /teamvite/Gemfile
COPY Gemfile.lock /teamvite/Gemfile.lock
RUN bundle install
COPY . /teamvite
CMD bin/server-start
