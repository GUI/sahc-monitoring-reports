source "https://rubygems.org"

ruby "~> 3.4.0"

gem "rails", "~> 8.0.2"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.5.9"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.6.0"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Error logging
gem "rollbar", "~> 3.6.1"

# Assets
gem "vite_rails", "~> 3.0.19"

# EXIF extraction from JPEGs
gem "exifr", "~> 1.4.1"

# Unzip KMZ files
gem "rubyzip", "~> 2.4.1", :require => "zip"

# HTML encoding
gem "htmlentities", "~> 4.3.4"

# File Uploads
gem "shrine", "~> 3.6.0"
gem "content_disposition", "~> 1.0.0"
gem "aws-sdk-s3", "~> 1.182"

# Resizing image uploads
gem "image_processing", "~> 1.14.0"

# Image optimization/compression for file uploads
gem "image_optimizer", "~> 1.9.0"

# Soft deletes
gem "paranoia", "~> 3.0.1"

# Per-request storage for storing userstamp info.
gem "request_store", "~> 1.7.0"

# PDF generation
gem "prawn", "~> 2.5.0"
# Required for prawn until > 2.4 is released for Ruby 3.1 compatibility:
# https://github.com/prawnpdf/prawn/issues/1235
gem "matrix"

# Form layouts
gem "simple_form", "~> 5.3.1"

# Authentication
gem "devise", "~> 4.9.4"
gem "omniauth", "~> 2.1.3"
gem "omniauth-google-oauth2", "~> 1.2.1"

# Fix for CVE-2015-9284: https://github.com/omniauth/omniauth/pull/809
gem "omniauth-rails_csrf_protection", "~> 1.0.2"

# Breadcrumbs
gem "gretel", "~> 5.0.1"

# Background jobs
gem "queue_classic", "~> 4.0.0"

# KML parsing
gem "rexml", "~> 3.4.1"

# Health check endpoint
gem "health-monitor-rails", "~> 12.6.0"
gem "faraday"

# Production logging
gem "lograge", "~> 0.14.0"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Development configuration
  gem "dotenv-rails", "~> 3.1.7"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
