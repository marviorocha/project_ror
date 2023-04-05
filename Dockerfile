FROM library/ruby:3.1.0-alpine

RUN apk --update add make g++
RUN apk update && apk add git

ARG RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
ARG DATABASE_URL=${DATABASE_URL}
ENV DATABASE_URL=${DATABASE_URL}
ARG SECRET_KEY_BASE=${SECRET_KEY_BASE}
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}

RUN apk update && apk upgrade && \
  apk add --no-cache make g++ git postgresql-dev

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY ./Gemfile /usr/src/app/
RUN bundle install
COPY ./ /usr/src/app
ENV RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="true" \
    RAILS_ENV="production" \
    BUNDLE_WITHOUT="development"

COPY ./entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
#RUN EDITOR='code --w' bin/rails credentials:edit
RUN bundle exec rails assets:precompile db:migrate
#RUN RAILS_ENV=production bundle exec rake db:create db:schema:load

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
EXPOSE 80
WORKDIR /usr/src/app
CMD ["rackup", "config.ru", "--host", "0.0.0.0", "--port", "80"]"
