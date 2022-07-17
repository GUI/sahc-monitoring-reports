FROM ruby:3.1.2-bullseye

ENV \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3 \
  DOCKER=true \
  EDITOR=nano \
  LANG=C.UTF-8 \
  NODE_OPTIONS=--use-openssl-ca \
  NODE_MODULES_DIR=/usr/local/node_modules \
  NOKOGIRI_USE_SYSTEM_LIBRARIES=1 \
  RAILS_LOG_TO_STDOUT=true \
  RAILS_SERVE_STATIC_FILES=true \
  RAILS_ENABLE_DELAYED_JOB=true \
  PORT=3000 \
  DEV_CACHE_DIR=/dev-cache

# Determine Debian version
RUN apt-get update && \
  apt-get -y install lsb-release && \
  rm -rf /var/lib/apt/lists/*

# For editing encrypted secrets
RUN apt-get update && \
  apt-get -y install nano vim && \
  rm -rf /var/lib/apt/lists/*

# rsync for syncing files.
RUN apt-get update && \
  apt-get -y install rsync && \
  rm -rf /var/lib/apt/lists/*

# Postgresql
ARG POSTGRESQL_VERSION=13
RUN set -x && \
  distro="$(lsb_release -s -c)" && \
  echo "deb http://apt.postgresql.org/pub/repos/apt/ ${distro}-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
  curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
  apt-get update && \
  apt-get -y install "postgresql-client-${POSTGRESQL_VERSION}" && \
  pg_dump --version | grep --fixed-strings "(PostgreSQL) ${POSTGRESQL_VERSION}." && \
  rm -rf /var/lib/apt/lists/*

# NodeJS and Yarn
ARG NODEJS_VERSION=16
RUN set -x && \
  version="node_${NODEJS_VERSION}.x" && \
  distro="$(lsb_release -s -c)" && \
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
  echo "deb http://deb.nodesource.com/$version $distro main" > /etc/apt/sources.list.d/nodesource.list && \
  echo "deb-src http://deb.nodesource.com/$version $distro main" >> /etc/apt/sources.list.d/nodesource.list && \
  curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb http://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
  apt-get update && \
  apt-get -y install nodejs yarn && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir /app
WORKDIR /app

# Copy only files for bundle install (so we only bundle when the gemfile
# changes).
COPY Gemfile Gemfile.lock /app/
RUN bundle install
ARG BUNDLE_INSTALL_ARGS="--frozen --without=development test"
RUN set -x && bundle install $BUNDLE_INSTALL_ARGS && bundle clean --force --verbose

# Install NPM dependencies.
COPY package.json yarn.lock /app/
ARG YARN_INSTALL_ARGS="--frozen-lockfile"
RUN set -x && \
  mkdir -p "$NODE_MODULES_DIR" && \
  ln -s "$NODE_MODULES_DIR" /app/node_modules && \
  yarn install $YARN_INSTALL_ARGS

# Copy the rest of the app.
COPY . /app

ENTRYPOINT ["/app/bin/docker-entrypoint", "--"]
CMD ["/app/bin/docker-start"]
