class ReportPdfJob < ApplicationJob
  def perform(report_id)
    Report.transaction do
      begin
        report = Report.find(report_id)

        report.generate_pdf
        report.save!(:touch => false)
      rescue => e
        if report
          report.update_column(:pdf_progress, "failure")
        end

        raise e
      end
    end
  end
end
