class PhotoImageUploader < ApplicationUploader
  Attacher.validate do
    validate_extension_inclusion [
      "jpeg",
      "jpg",
    ]
    validate_mime_type_inclusion [
      "image/jpeg",
    ]
  end

  Attacher.derivatives do |original|
    processing = ImageProcessing::Vips.source(original)
    default = processing.resize_to_limit(700, 700).call

    default_optimizer = ImageOptimizer.new(default.path, :quality => 80)
    default_optimizer.optimize

    {
      :default => File.open(default_optimizer.path, "rb"),
    }
  end
end
