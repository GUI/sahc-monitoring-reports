class ReportUploadsJob < ApplicationJob
  def perform(report_id, upload_uuids, current_user_email)
    report = Report.find(report_id)

    Upload.transaction do
      RequestStore.store[:current_user_email] = current_user_email

      upload_uuids.each do |uuid|
        Rails.logger.info("BEFORE UPLOAD FIND: #{uuid.inspect}")
        upload = Upload.find_by!(:uuid => uuid)
        Rails.logger.info("AFTER UPLOAD FIND: #{uuid.inspect}")
        upload.build_photos.each do |photo|
          Rails.logger.info("INSIDE BUILD PHOTOS EACH: #{uuid.inspect}")
          Rails.logger.info("INSIDE BUILD PHOTOS EACH: #{photo.inspect}")
          photo.report_id = report.id
          Rails.logger.info("BEFORE PHOTO SAVE: #{uuid.inspect}")
          photo.save!
          Rails.logger.info("AFTER PHOTO SAVE: #{uuid.inspect}")
        end
        Rails.logger.info("BEFORE UPLOAD DESTROY: #{uuid.inspect}")
        upload.destroy
        Rails.logger.info("AFTER UPLOAD DESTROY: #{uuid.inspect}")
      end
    end

    report.update_column(:upload_progress, nil)

    Upload.cleanup_old!
  rescue => e
    if report
      report.update_column(:upload_progress, "failure")
    end

    raise e
  end
end
