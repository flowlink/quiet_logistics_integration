FROM rlister/ruby:2.1.6
MAINTAINER Ric Lister <ric@spreecommerce.com>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -yq \
    build-essential \
    zlib1g-dev \
    libreadline6-dev \
    libyaml-dev \
    libssl-dev \
    libxslt-dev \
    libxml2-dev \
    git

RUN gem install bundler --no-rdoc --no-ri

## help docker cache bundle
WORKDIR /tmp
ADD ./Gemfile /tmp/
ADD ./Gemfile.lock /tmp/
RUN bundle install
RUN rm -f /tmp/Gemfile /tmp/Gemfile.lock

WORKDIR /app
ADD ./ /app

EXPOSE 5000

ENTRYPOINT [ "bundle", "exec" ]
# CMD [ "foreman", "start" ]

## this is a nasty hack, but without it foreman throws:
## `setpgrp': Operation not permitted (Errno::EPERM)
CMD [ "bash -c 'true && foreman start'"]
