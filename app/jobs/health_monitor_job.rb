class HealthMonitorJob < ApplicationJob
  def perform
    ApplicationRecord.connection.execute("SELECT 1")
    if ENV["HEALTH_MONITOR_HEARTBEAT_URL"]
      conn = Faraday.new do |faraday|
        faraday.request :instrumentation
        faraday.response :raise_error
      end

      conn.get(ENV["HEALTH_MONITOR_HEARTBEAT_URL"])
    end
  end
end

HealthMonitorJob.logger = Logger.new(IO::NULL)
