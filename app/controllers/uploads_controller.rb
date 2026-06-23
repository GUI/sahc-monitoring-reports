class UploadsController < ApplicationController
  def index
    uploads = []
    if(params[:uuids].present?)
      uuids = params[:uuids].split(",")
      uploads = Upload.where(:uuid => uuids).all
    end

    data = uploads.map do |upload|
      {
        :uuid => upload.uuid,
        :name => upload.file.original_filename,
        :type => upload.file.mime_type,
        :size => upload.file.size,
      }
    end

    render :json => data
  end

  def create
    begin
      # If an upload fails, then it may be retried with the same UUID, so find
      # or create based on the UUID.
      upload = Upload.find_or_initialize_by(:uuid => upload_params[:uuid])
      upload.assign_attributes(upload_params)
      upload.save!
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    render :json => { :success => true }
  end

  def destroy
    upload = Upload.find_by!(:uuid => params[:id])
    upload.destroy!

    render :json => { :success => true }
  end

  private

  def upload_params
    params.permit(:uuid, :file)
  end
end
