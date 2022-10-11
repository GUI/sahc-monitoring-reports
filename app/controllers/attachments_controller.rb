class AttachmentsController < ApplicationController
  def download
    # Use this approach instead of the Rails `fresh_when` so we have a simpler
    # conditional based purely on the etag (the Rails implementation seems to
    # combine other aspects).
    self.headers["ETag"] = param_etag
    if request.fresh?(response)
      return head :not_modified
    end

    set_rack_response ApplicationUploader.download_response(request.env)
  end

  private

  def set_rack_response((status, headers, body))
    self.status = status
    self.headers.merge!(headers)

    if status == 200
      self.headers["ETag"] = param_etag
      self.headers["Cache-Control"] = "private, no-cache, max-age=31536000, immutable"
    else
      self.headers.delete("ETag")
      self.headers["Cache-Control"] = "private, no-cache"
    end

    self.response_body = body
  end

  def param_etag
    # The URL parameter is unique if the data changes at all, so we can use it
    # as the etag.
    @param_etag ||= Digest::SHA256.hexdigest(params[:rest])[0, 20]
  end
end
