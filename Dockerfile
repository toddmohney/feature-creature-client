FROM ruby:2.2.4

COPY . "$HOME/feature-creature-client"

WORKDIR "$HOME/feature-creature-client"

RUN bundle install

CMD rackup -p 4567
