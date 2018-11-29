FROM ruby:2.2.5
WORKDIR /workspace
COPY . /workspace
RUN bundle install
RUN bundle exec rake
