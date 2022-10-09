class AttachmentsController < ApplicationController
  def download
    set_rack_response ApplicationUploader.download_response(request.env)
  end

  private

  def set_rack_response((status, headers, body))
    self.status = status
    self.headers.merge!(headers)

    if status == 200
      self.headers["Cache-Control"] = "private, no-cache, max-age=31536000, immutable"
    end

    self.response_body = body
  end
end
