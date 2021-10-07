FROM ruby:3.0.2

# Operating system dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client

RUN mkdir /teamvite
WORKDIR /teamvite

# Application dependencies
COPY Gemfile /teamvite
COPY Gemfile.lock /teamvite
RUN bundle install

# Source code
COPY . /teamvite
CMD bin/server-start
