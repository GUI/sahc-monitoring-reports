source "https://rubygems.org"

ruby "~> 3.1.2"

gem "rails", "~> 7.0.3"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.4.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.6.4"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Error logging
gem "rollbar", "~> 3.3.1"

# Assets
gem "vite_rails", "~> 3.0.10"

# EXIF extraction from JPEGs
gem "exifr", "~> 1.3.5"

# Unzip KMZ files
gem "rubyzip", "~> 2.3.2", :require => "zip"

# HTML encoding
gem "htmlentities", "~> 4.3.4"

# File Uploads
gem "carrierwave", "~> 1.3.1"
gem "carrierwave-postgresql-table", "~> 1.1.0"
gem "mini_magick", "~> 4.11.0"

# Soft deletes
gem "paranoia", "~> 2.6.0"

# Userstamping
#
# Use master to fix loading issues with delayed_job:
# https://github.com/lowjoel/activerecord-userstamp/pull/12
# gem "activerecord-userstamp", "~> 3.0.5", :git => "https://github.com/lowjoel/activerecord-userstamp.git"

# PDF generation
gem "prawn", "~> 2.4.0"

# Form layouts
gem "simple_form", "~> 5.1.0"

# Authentication
gem "devise", "~> 4.8.1"
gem "omniauth", "~> 2.1.0"
gem "omniauth-google-oauth2", "~> 1.0.1"

# Fix for CVE-2015-9284: https://github.com/omniauth/omniauth/pull/809
gem "omniauth-rails_csrf_protection", "~> 1.0.1"

# Breadcrumbs
gem "gretel", "~> 4.4.0"

# Background jobs
gem "delayed_job_active_record", "~> 4.1.1"
gem "daemons", "~> 1.3.1"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]

  # Add comments to models describing the available columns
  gem "annotate", "~> 3.2.0"

  # Development configuration
  gem "dotenv-rails", "~> 2.7.2"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
