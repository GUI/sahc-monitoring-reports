class AttachmentsController < ApplicationController
  def download
    fresh_when(strong_etag: param_etag)

    set_rack_response ApplicationUploader.download_response(request.env)
  end

  private

  def set_rack_response((status, headers, body))
    self.status = status
    self.headers.merge!(headers)

    if status == 200
      self.headers["ETag"] = param_etag
      self.headers["Cache-Control"] = "private, no-cache, max-age=31536000, immutable"
    end

    self.response_body = body
  end

  def param_etag
    # The URL parameter is unique if the data changes at all, so we can use it
    # as the etag.
    @param_etag ||= Digest::SHA256.hexdigest(params[:rest])[0, 20]
  end
end
