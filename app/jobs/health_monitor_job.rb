require "open-uri"

class HealthMonitorJob < ApplicationJob
  def perform
    ApplicationRecord.connection.execute("SELECT 1")
    if ENV["HEALTH_MONITOR_HEARTBEAT_URL"]
      URI.open(ENV["HEALTH_MONITOR_HEARTBEAT_URL"]).read
    end
  end
end
