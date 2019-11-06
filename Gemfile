source "https://rubygems.org"

ruby "2.6.3"

gem "rails", "~> 5.2.1"

# Process management
gem "foreman", "~> 0.85.0"

# Server
gem "puma", "~> 4.1.0"

# PostgreSQL
gem "pg", "~> 1.1.3"

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 4.0"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

# Error logging
gem "rollbar", "~> 2.22.0"

# EXIF extraction from JPEGs
gem "exifr", "~> 1.3.5"

# Unzip KMZ files
gem "rubyzip", "~> 1.3.0", :require => "zip"

# HTML encoding
gem "htmlentities", "~> 4.3.4"

# File Uploads
gem "carrierwave", "~> 1.3.1"
gem "carrierwave-postgresql-table", "~> 1.1.0"
gem "mini_magick", "~> 4.9.2"

# Soft deletes
gem "paranoia", "~> 2.4.1"

# Userstamping
#
# Use master to fix loading issues with delayed_job:
# https://github.com/lowjoel/activerecord-userstamp/pull/12
gem "activerecord-userstamp", "~> 3.0.5", :git => "https://github.com/lowjoel/activerecord-userstamp.git"

# PDF generation
gem "prawn", "~> 2.2.2"

# Form layouts
gem "simple_form", "~> 4.1.0"

# Authentication
gem "devise", "~> 4.7.1"
gem "omniauth", "~> 1.9.0"
gem "omniauth-google-oauth2", "~> 0.8.0"

# Fix for CVE-2015-9284: https://github.com/omniauth/omniauth/pull/809
gem "omniauth-rails_csrf_protection", "~> 0.1.0"

# Breadcrumbs
gem "gretel", "~> 3.0.9"

# Background jobs
gem "delayed_job_active_record", "~> 4.1.1"
gem "daemons", "~> 1.3.1"

# Prevent long-running requests.
gem "rack-timeout", "~> 0.5.1", :require => "rack/timeout/base"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]

  # Add comments to models describing the available columns
  #
  # Use master for Ruby 2.4 deprecation warning fixes.
  gem "annotate", "~> 2.7.4"

  # Development configuration
  gem "dotenv-rails", "~> 2.7.2"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem "chromedriver-helper"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
