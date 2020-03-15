FROM ruby:2.6.5-buster

# Determine Debian version
RUN apt-get update && apt-get -y install lsb-release

# For editing encrypted secrets
RUN apt-get update && apt-get -y install nano vim

# Postgresql (10.0)
RUN set -x && \
  DISTRO="$(lsb_release -s -c)" && \
  curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
  echo "deb http://apt.postgresql.org/pub/repos/apt/ ${DISTRO}-pgdg main 10" > /etc/apt/sources.list.d/pgdg.list && \
  apt-get update && \
  apt-get -y install postgresql-client-10 && \
  pg_config --version && \
  psql --version | grep --fixed-strings "(PostgreSQL) 10."

# NodeJS and Yarn
RUN set -x && \
  VERSION=node_10.x && \
  DISTRO="$(lsb_release -s -c)" && \
  curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
  echo "deb http://deb.nodesource.com/$VERSION $DISTRO main" > /etc/apt/sources.list.d/nodesource.list && \
  echo "deb-src http://deb.nodesource.com/$VERSION $DISTRO main" >> /etc/apt/sources.list.d/nodesource.list && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb http://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
  apt-get update && \
  apt-get -y install nodejs yarn

RUN mkdir /app
WORKDIR /app

# Copy only files for bundle install (so we only bundle when the gemfile
# changes).
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES 1
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# Copy only files for yarn install.
COPY package.json /app/package.json
COPY yarn.lock /app/yarn.lock
RUN mkdir -p /usr/local/node_modules && \
  ln -s /usr/local/node_modules ./node_modules && \
  yarn

# Copy the rest of the app.
COPY . /app

ENV LANG C.UTF-8
ENV EDITOR nano
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_ENABLE_DELAYED_JOB true
ENV DOCKER true

CMD ./bin/docker-start
