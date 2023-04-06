FROM library/ruby:3.1.0-alpine

RUN apk --update add make g++
RUN apk update && apk add git



RUN apk add --update --no-cache \
  binutils-gold \
  build-base \
  openssh \
  curl \
  file \
  g++ \
  gcc \
  git \
  less \
  libstdc++ \
  libffi-dev \
  libc-dev \
  linux-headers \
  libxml2-dev \
  libxslt-dev \
  libgcrypt-dev \
  make \
  netcat-openbsd \
  nodejs \
  openssl \
  bash \
  pkgconfig \
  postgresql-dev \
  tzdata \
  yarn \
  imagemagick \
  graphicsmagick-dev \
  ruby-dev \
  musl-dev
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY ./Gemfile /usr/src/app/
RUN bundle install
COPY ./ /usr/src/app

ARG DATABASE_URL=${DATABASE_URL} \
    SECRET_KEY_BASE=${SECRET_KEY_BASE}

ENV RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="true" \
    RAILS_ENV="production" \
    BUNDLE_WITHOUT="development" \
    DATABASE_URL=${DATABASE_URL} \
    SECRET_KEY_BASE=${SECRET_KEY_BASE}

COPY ./entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh


RUN bundle exec rails assets:precompile

ENTRYPOINT ["entrypoint.sh"]
EXPOSE 80
WORKDIR /usr/src/app
CMD ["rackup", "config.ru", "--host", "0.0.0.0", "--port", "80"]"
