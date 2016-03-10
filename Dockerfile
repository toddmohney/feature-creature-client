FROM ruby:2.2.4

COPY . /usr/local/feature-creature-client

WORKDIR "/usr/local/feature-creature-client"

RUN bundle install

# logging
RUN mkdir /usr/local/feature-creature-client/log
VOLUME [ "/usr/local/feature-creature-client/log" ]

CMD rackup --host 0.0.0.0 --port 4567
