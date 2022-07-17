class UploadFileUploader < ApplicationUploader
  Attacher.validate do
    validate_extension_inclusion [
      "jpeg",
      "jpg",
      "kmz",
    ]
    validate_mime_type_inclusion [
      "image/jpeg",
      "application/vnd.google-earth.kmz",
    ]
  end
end
