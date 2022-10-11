namespace :shrine do
  desc "Clean temporary cached upload files older than 24 hours"
  task :clean_cached_files => :environment do
    Upload.cleanup_old!

    # Eventually this would be nice to replace with lifecycle policies, but
    # current object storage doesn't support those, so we must manually purge
    # old temp files periodically.
    Shrine.storages.fetch(:cache).clear! do |object|
      if object.last_modified < Time.now - 2.days
        puts "Deleting #{object.key} (#{object.last_modified.iso8601})"
        true
      else
        false
      end
    end
  end
end
