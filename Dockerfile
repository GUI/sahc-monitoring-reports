###
# Build
###
FROM ruby:3.1-slim-bullseye AS build

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

# Build dependencies
RUN apt-get update && \
  apt-get -y install build-essential curl gpg lsb-release && \
  rm -rf /var/lib/apt/lists/*

# For editing encrypted secrets
RUN apt-get update && \
  apt-get -y install nano vim && \
  rm -rf /var/lib/apt/lists/*

# rsync for syncing files.
RUN apt-get update && \
  apt-get -y install rsync && \
  rm -rf /var/lib/apt/lists/*

# For image resizing/manipulation.
RUN apt-get update && \
  apt-get -y install file libvips libheif-dev && \
  rm -rf /var/lib/apt/lists/*

# For image optimization.
RUN apt-get update && \
  apt-get -y install jpegoptim optipng gifsicle pngquant && \
  rm -rf /var/lib/apt/lists/*

# Postgresql
ARG POSTGRESQL_VERSION=14
RUN set -x && \
  distro="$(lsb_release -s -c)" && \
  curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor > /usr/share/keyrings/pgdg.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt/ ${distro}-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
  apt-get update && \
  apt-get -y install libpq-dev "postgresql-client-${POSTGRESQL_VERSION}" && \
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
RUN set -x && \
  bundle install $BUNDLE_INSTALL_ARGS && \
  bundle clean --force --verbose && \
  rm -rf /usr/local/bundle/cache/*.gem && \
  find /usr/local/bundle/gems -name "*.c" -print -delete && \
  find /usr/local/bundle/gems -name "*.o" -print -delete

# Install NPM dependencies.
COPY package.json yarn.lock /app/
ARG YARN_INSTALL_ARGS="--frozen-lockfile"
RUN set -x && \
  mkdir -p "$NODE_MODULES_DIR" && \
  ln -s "$NODE_MODULES_DIR" /app/node_modules && \
  yarn install $YARN_INSTALL_ARGS

# Precompile assets.
COPY Rakefile vite.config.ts /app/
COPY app/frontend /app/app/frontend
COPY bin /app/bin
COPY config /app/config
ARG PRECOMPILE_ASSETS=true
RUN set -x && \
  if [ "$PRECOMPILE_ASSETS" = "true" ]; then \
    RAILS_ENV=production RAILS_PRECOMPILE=true bundle exec rails assets:precompile --trace && \
    rm -rf /app/tmp; \
  fi

# Copy the rest of the app.
COPY . /app

ENTRYPOINT ["/app/bin/docker-entrypoint", "--"]
CMD ["/app/bin/docker-start"]

###
# Runtime
###
FROM ruby:3.1-slim-bullseye AS runtime
WORKDIR /app

# For image resizing/manipulation.
# For image optimization.
# Postgresql
COPY --from=build /usr/share/keyrings/pgdg.gpg  /usr/share/keyrings/pgdg.gpg
COPY --from=build /etc/apt/sources.list.d/pgdg.list /etc/apt/sources.list.d/pgdg.list 
ARG POSTGRESQL_VERSION=14
RUN set -x && \
  apt-get update && \
  apt-get -y install file libvips libheif-dev && \
  apt-get -y install jpegoptim optipng gifsicle pngquant && \
  apt-get -y install "postgresql-client-${POSTGRESQL_VERSION}" && \
  pg_dump --version | grep --fixed-strings "(PostgreSQL) ${POSTGRESQL_VERSION}." && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

ENV \
  DOCKER=true \
  LANG=C.UTF-8 \
  RAILS_LOG_TO_STDOUT=true \
  RAILS_SERVE_STATIC_FILES=true \
  RAILS_ENABLE_DELAYED_JOB=true \
  PORT=3000

EXPOSE 3000
ENTRYPOINT ["/app/bin/docker-entrypoint", "--"]
CMD ["/app/bin/docker-start"]
