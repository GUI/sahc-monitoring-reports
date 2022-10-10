class ReportPdfJob < ApplicationJob
  def perform(report_id)
    report = Report.find(report_id)

    Report.transaction do
      report.generate_pdf
      report.save!(:touch => false)
    end
  rescue => e
    if report
      report.update_column(:pdf_progress, "failure")
    end

    raise e
  end
end
