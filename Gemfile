source "https://rubygems.org"

ruby "~> 3.1.2"

gem "rails", "~> 7.0.3"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.4.3"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.6.5"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Error logging
gem "rollbar", "~> 3.3.1"

# Assets
gem "vite_rails", "~> 3.0.12"

# EXIF extraction from JPEGs
gem "exifr", "~> 1.3.5"

# Unzip KMZ files
gem "rubyzip", "~> 2.3.2", :require => "zip"

# HTML encoding
gem "htmlentities", "~> 4.3.4"

# File Uploads
gem "shrine", "~> 3.4.0"
gem "aws-sdk-s3", "~> 1.114"
gem "mini_magick", "~> 4.11.0"

# Resizing image uploads
gem "image_processing", "~> 1.12.2"

# Image optimization/compression for file uploads
gem "image_optimizer", "~> 1.9.0"

# Soft deletes
gem "paranoia", "~> 2.6.0"

# Per-request storage for storing userstamp info.
gem "request_store", "~> 1.5.1"

# PDF generation
gem "prawn", "~> 2.4.0"
# Required for prawn until > 2.4 is released for Ruby 3.1 compatibility:
# https://github.com/prawnpdf/prawn/issues/1235
gem "matrix"

# Form layouts
gem "simple_form", "~> 5.1.0"

# Authentication
gem "devise", "~> 4.8.1"
gem "omniauth", "~> 2.1.0"
gem "omniauth-google-oauth2", "~> 1.1.1"

# Fix for CVE-2015-9284: https://github.com/omniauth/omniauth/pull/809
gem "omniauth-rails_csrf_protection", "~> 1.0.1"

# Breadcrumbs
gem "gretel", "~> 4.4.0"

# Background jobs
gem "queue_classic", "~> 4.0.0"

# KML parsing
gem "rexml", "~> 3.2.5"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]

  # Add comments to models describing the available columns
  gem "annotate", "~> 3.2.0"

  # Development configuration
  gem "dotenv-rails", "~> 2.8.1"
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
