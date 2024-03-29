# frozen_string_literal: true

# Load the Rails application.
require_relative "application"
require_relative "rollbar"

# Initialize the Rails application.
notify = lambda do |e|
  Rollbar.with_config(use_async: false) do
    Rollbar.error(e)
  end
rescue
  Rails.logger.error "Synchronous Rollbar notification failed.  Sending async to preserve info"
  Rollbar.error(e)
end

begin
  Rails.application.initialize!
rescue Exception => e
  notify.call(e)
  raise
end
