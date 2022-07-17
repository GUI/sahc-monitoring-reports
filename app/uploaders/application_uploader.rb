class ApplicationUploader < Shrine
  plugin :activerecord
  plugin :cached_attachment_data
  plugin :derivatives, :create_on_promote => true
  plugin :determine_mime_type
  plugin :signature
  plugin :pretty_location
  plugin :remove_attachment
  plugin :remove_invalid
  plugin :restore_cached_data
  plugin :tempfile
  plugin :validation_helpers
end
