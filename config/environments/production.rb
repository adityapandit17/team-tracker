# frozen_string_literal: true

# Soften production SSL for local demos; set FORCE_SSL=true in real prod.
Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.log_level = :info
  config.force_ssl = ENV["FORCE_SSL"] == "true"
  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST", "localhost") }

  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }
end
