# frozen_string_literal: true

Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  config.action_controller.perform_caching = false
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  config.hosts.clear

  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }
  config.solid_queue.logger = ActiveSupport::Logger.new(STDOUT)
end
