require "exifr/jpeg"
require "rexml/document"

# == Schema Information
#
# Table name: uploads
#
#  id                :integer          not null, primary key
#  uuid              :string(36)       not null
#  file              :string(255)      not null
#  file_size         :integer          not null
#  file_content_type :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  creator_id        :integer
#  updater_id        :integer
#
# Indexes
#
#  index_uploads_on_uuid  (uuid) UNIQUE
#

class Upload < ApplicationRecord
  # File attachments
  include UploadFileUploader::Attachment.new(:file)

  # Callbacks
  before_validation :set_file_metadata

  # Validations
  validates :uuid, :presence => true
  validates :file, :presence => true
  validates :file_size, :presence => true
  validates :file_content_type, :presence => true

  def build_photos
    photos = []

    case(self.file_content_type)
    when "application/vnd.google-earth.kmz"
      photos += build_photos_from_kmz
    when "image/heic", "image/jpeg"
      photos << build_photo_from_jpeg
    else
      raise "Unknown extension"
    end

    photos
  end

  private

  def set_file_metadata
    if self.file
      self.file_content_type = self.file.mime_type
      self.file_size = self.file.size
    end
  end

  def build_photos_from_kmz
    photos = []

    coder = HTMLEntities.new
    Zip::File.open(self.file.file.to_tempfile) do |zip_file|
      doc = REXML::Document.new(zip_file.glob("doc.kml").first.get_input_stream.read)
      zip_file.glob("files/*.jpg").each do |zip_entry|
        filename = File.basename(zip_entry.name)

        description = doc.elements.to_a("/kml/Document/Placemark/description").find do |description|
          description.text.include?(zip_entry.name)
        end

        description = REXML::Document.new("<root>#{description.text}</root>")
        subtitle_elem = description.elements["//div[@id='com.miocool.mapplus.subtitle']"]
        if(subtitle_elem)
          subtitle = coder.decode(subtitle_elem.text.strip)
        end

        begin
          # Create a tempfile inside a temporary directory (rather than using
          # Tempfile), so that the filename matches the original filename.
          dir = Dir.mktmpdir
          path = File.join(dir, filename)
          zip_entry.extract(path)
          image = File.open(path, "rb")

          photo = build_photo(image)
          photo.assign_attributes({
            :caption => subtitle,
          })

          photos << photo
        ensure
          image.close if(image)
          FileUtils.remove_entry(dir) if(dir)
        end
      end
    end

    photos
  end

  def build_photo_from_jpeg
    photo = nil
    self.file.open do
      photo = build_photo(self.file.tempfile, filename: self.file.original_filename)
    end

    photo
  end

  def build_photo(image, filename: nil)
    large = ImageProcessing::Vips
      .loader(autorot: true)
      .source(image)
      .convert("jpeg")
      .resize_to_limit(3000, 3000)
      .call

    exif = EXIFR::JPEG.new(large)

    photo = Photo.new({
      :image => large,
      :taken_at => exif.date_time_original,
    })

    if filename
      photo.image.metadata["filename"] = filename
    end

    if(!photo.taken_at && exif.gps_date_stamp && exif.gps_time_stamp)
      date = exif.gps_date_stamp
      time = exif.gps_time_stamp
      photo.taken_at = Time.use_zone("UTC") { Time.zone.strptime("#{date} #{time[0].to_i}:#{time[1].to_i}:#{format("%.3f", time[2])}", "%Y:%m:%d %H:%M:%S.%L") }
    end

    if(exif.gps)
      photo.assign_attributes({
        :latitude => exif.gps.latitude,
        :longitude => exif.gps.longitude,
        :altitude => exif.gps.altitude,
        :image_direction => exif.gps.image_direction,
      })
    end

    photo
  end
end
