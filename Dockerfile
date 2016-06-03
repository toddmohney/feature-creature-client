FROM ruby:2.2.4

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -

RUN apt-get update
RUN apt-get install -y \
    build-essential \
    nodejs

RUN npm install -g elm

COPY . /usr/local/feature-creature-client

VOLUME /usr/local/feature-creature-client

WORKDIR "/usr/local/feature-creature-client"

RUN bundle install
RUN elm make src/Main.elm --warn --output public/js/elm.js

CMD rackup --host 0.0.0.0 --port 4567
