# frozen_string_literal: true

Rails.application.config.secret_key_base = ENV.fetch(
  "SECRET_KEY_BASE",
  "0a1b2c3d4e5f67890123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
)
