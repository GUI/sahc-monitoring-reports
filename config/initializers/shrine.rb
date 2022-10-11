# frozen_string_literal: true

# Cache S3 storage files locally to reduce bandwidth usage on object storage (to
# try and stay below free limits).
module ShrineCachedS3
  MAX_BYTE_SIZE = 512 * 1024 * 1024 # 512MB

  # Use Moneta to cache in a postgresql table.
  def cache_store
    @cache_store ||= begin
      db_config = Rails.application.config.database_configuration.fetch(Rails.env)

      if db_config["url"].present?
        cache_db_config = db_config["url"]
      else
        cache_db_config = {
          :adapter => "postgres",
          :host => db_config["host"],
          :user => db_config["username"],
          :password => db_config["password"],
          :database => db_config["database"],
        }
      end

      cache = Moneta::Adapters::Sequel.new(
        :db => cache_db_config,
        :create_table => false,
        :table => :moneta_cache,
        :key_column => :key,
        :value_column => :value,
        :logger => Rails.logger,
      )
    end
  end

  def open(id, rewindable: true, encoding: nil, **options)
    # Don't try to cache the temporary upload files since these are larger and
    # only used once when converting to the normal files.
    if id.start_with?("upload/")
      return super
    end

    # Look for a cached value.
    value = cache_store[id]

    # If not cached, then fetch the file as normal and cache it. Note that this
    # does end up reading the file as a string, so the file is no longer
    # streamed back. This may increase memory usage, but should be okay with the
    # smaller photo files we're caching here.
    if value.nil?
      value = super.read
      cache_store[id] = value

      # When storing new cache entries, purge older ones that cause the database
      # to exceed our desired size.
      cache_store.backend.execute <<~SQL
        DELETE from moneta_cache
        USING (
          SELECT key, sum(value_size) OVER (ORDER BY created_at DESC ROWS UNBOUNDED PRECEDING) AS total_size
          FROM moneta_cache
        ) AS sums
        WHERE moneta_cache.key = sums.key AND sums.total_size > #{MAX_BYTE_SIZE};
      SQL
    end

    StringIO.new(value)
  end
end

if Rails.env.development? || Rails.env.test? || ENV["RAILS_PRECOMPILE"]
  require "shrine/storage/file_system"

  Shrine.storages = {
    :cache => Shrine::Storage::FileSystem.new(Rails.root.join("public"), :prefix => "uploads/tmp"),
    :store => Shrine::Storage::FileSystem.new(Rails.root.join("public"), :prefix => "uploads"),
  }
else
  require "shrine/storage/s3"

  Shrine::Storage::S3.prepend(ShrineCachedS3)

  options = {
    :endpoint => ENV.fetch("S3_ENDPOINT"),
    :region => ENV.fetch("S3_REGION"),
    :access_key_id => ENV.fetch("S3_ACCESS_KEY_ID"),
    :secret_access_key => ENV.fetch("S3_SECRET_ACCESS_KEY"),
    :bucket => ENV.fetch("S3_BUCKET"),
    :prefix => Rails.env.to_s,
  }
  Shrine.storages = {
    :cache => Shrine::Storage::S3.new(**options.merge(:prefix => "#{options.fetch(:prefix)}/tmp")),
    :store => Shrine::Storage::S3.new(**options),
  }
end

if Rails.env.development? || Rails.env.test?
  Shrine.plugin :instrumentation
end

Shrine.plugin :download_endpoint, :prefix => "attachments", :disposition => "attachment"
