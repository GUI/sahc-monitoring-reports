class ApplicationUploader < Shrine
  plugin :activerecord
  plugin :add_metadata
  plugin :cached_attachment_data
  plugin :derivatives, :create_on_promote => true
  plugin :determine_mime_type
  plugin :pretty_location
  plugin :remove_attachment
  plugin :remove_invalid
  plugin :restore_cached_data
  plugin :signature
  plugin :tempfile
  plugin :validation_helpers

  add_metadata :sha256 do |io|
    calculate_signature(io, :sha256)
  end
end
