class ReportsController < ApplicationController
  def index
    @reports = Report.order(:created_at => :desc).all
  end

  def show
    @report = Report.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render :json => @report }
    end
  end

  def new
    @report = Report.new(:monitoring_year => Date.today.year)
  end

  def create
    @report = Report.new
    save!
    redirect_to(edit_report_path(@report))
  rescue ActiveRecord::RecordInvalid
    render(:action => "new")
  end

  def edit
    if(params[:new_uploads])
      flash.now[:notice] = "New photos added. Update captions below."
    end

    @report = Report.find(params[:id])
  end

  def update
    @report = Report.find(params[:id])
    save!
    @report.reload
    if(@report.upload_progress == "pending")
      redirect_to(edit_report_path(@report))
    else
      flash[:notice] = "Successfully saved changes."
      redirect_to(report_path(@report))
    end
  rescue ActiveRecord::RecordInvalid
    render(:action => "edit")
  end

  def destroy
    @report = Report.find(params[:id])
    @report.destroy

    flash[:notice] = "Successfully deleted #{@report.display_name} monitoring report"
    redirect_to(reports_path)
  end

  def download
    @report = Report.find(params[:id])
    if @report.pdf && @report.pdf_progress.nil?
      return redirect_to(@report.pdf.url, allow_other_host: true)
    end

    @report.queue_pdf_job
  end

  private

  def save!
    @report.assign_attributes(report_params)
    @report.save!
  end

  def report_params
    params.require(:report).permit([
      :type,
      :property_name,
      :monitoring_year,
      :photographer_name,
      :photo_starting_num,
      { :extra_signatures => [] },
      { :upload_uuids => [] },
      {
        :photos_attributes => [
          :id,
          :caption,
          :upload_uuid,
          :_destroy,
        ],
      }
    ])
  end
end
