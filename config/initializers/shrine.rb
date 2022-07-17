# frozen_string_literal: true

require "shrine/storage/s3"

options = {
  :endpoint => ENV.fetch("S3_ENDPOINT"),
  :region => ENV.fetch("S3_REGION"),
  :access_key_id => ENV.fetch("S3_ACCESS_KEY_ID"),
  :secret_access_key => ENV.fetch("S3_SECRET_ACCESS_KEY"),
  :bucket => ENV.fetch("S3_BUCKET"),
  :prefix => "#{Rails.env}",
}
Shrine.storages = {
  :cache => Shrine::Storage::S3.new(**options.merge(:prefix => "#{options.fetch(:prefix)}/tmp")),
  :store => Shrine::Storage::S3.new(**options),
}

if Rails.env.development? || Rails.env.test?
  Shrine.plugin :instrumentation
end

Shrine.plugin :derivatives, :create_on_promote => true
