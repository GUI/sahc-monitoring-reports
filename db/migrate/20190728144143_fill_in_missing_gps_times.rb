class FillInMissingGpsTimes < ActiveRecord::Migration[5.2]
  def up
    require "exifr/jpeg"

    Photo.where(:taken_at => nil).each do |photo|
      exif = EXIFR::JPEG.new(photo.image.file.to_tempfile)
      taken_at = exif.date_time_original
      if(!taken_at && exif.gps_date_stamp && exif.gps_time_stamp)
        date = exif.gps_date_stamp
        time = exif.gps_time_stamp
        taken_at = Time.use_zone("UTC") { Time.zone.strptime("#{date} #{time[0].to_i}:#{time[1].to_i}:#{format("%.3f", time[2])}", "%Y:%m:%d %H:%M:%S.%L") }
      end

      if taken_at
        photo.update_attribute(:taken_at, taken_at)
      end
    end
  end

  def down
  end
end
