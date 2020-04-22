class ResizeImages < ActiveRecord::Migration[5.2]
  def up
    photos = Photo.all
    photo_count = photos.count
    i = 1
    photos.each do |photo|
      puts "Photo #{i}/#{photo_count}: #{photo.id}"
      photo.image.recreate_versions!(:default)
      photo.image.recreate_versions!(:thumbnail)
      photo.save!
      i += 1
    end

    reports = Report.all
    report_count = reports.count
    i = 1
    reports.each do |report|
      puts "Report #{i}/#{report_count}: #{report.id}"
      if report.pdf.present?
        report.remove_pdf!
        report.save!
      end
      i += 1
    end

  end

  def down
  end
end
