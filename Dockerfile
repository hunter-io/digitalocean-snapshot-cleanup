FROM ruby:alpine

RUN apk update && \
  apk upgrade && \
  apk add build-base

RUN gem install droplet_kit rest-client

COPY entrypoint.rb /

CMD ["ruby", "entrypoint.rb"]
