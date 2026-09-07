# Per-request context so model callbacks know who is making a change.
class Current < ActiveSupport::CurrentAttributes
  attribute :user, :ip_address, :request_uuid, :audit_labels

  def actor_label
    user&.display_name || "System"
  end
end
