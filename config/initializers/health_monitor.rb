class HealthMonitor::Providers::QueueClassic < HealthMonitor::Providers::Base
  def check!
    HealthMonitorJob.perform_later
  end
end

HealthMonitor.configure do |config|
  config.database
  config.add_custom_provider(HealthMonitor::Providers::QueueClassic)
end
