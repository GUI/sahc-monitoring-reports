class ReportUploadsJob < ApplicationJob
  def perform(report_id, upload_uuids, current_user_email)
    Upload.transaction do
      begin
        report = Report.find(report_id)

        RequestStore.store[:current_user_email] = current_user_email

        upload_uuids.each do |uuid|
          upload = Upload.find_by!(:uuid => uuid)
          upload.build_photos.each do |photo|
            photo.report_id = report.id
            photo.save!
          end
          upload.destroy
        end

        report.update_column(:upload_progress, nil)
      rescue => e
        if report
          report.update_column(:upload_progress, "failure")
        end

        raise e
      end
    end
  end
end
