# Records every create / update / destroy into the audits table.
#
# Included by ApplicationRecord, so all models are audited by default.
# Opt a model out with `self.auditing_enabled = false`, and skip noisy
# columns with `self.audit_ignored_columns += %w[...]`.
#
# Note: update_columns / update_all / delete_all bypass callbacks and are
# therefore not audited — by design, those are maintenance-level operations.
module Auditable
  extend ActiveSupport::Concern

  BASE_IGNORED_COLUMNS = %w[
    id created_at updated_at
    encrypted_password reset_password_token reset_password_sent_at remember_created_at
  ].freeze

  LABEL_METHODS = %i[name title client_name display_name email].freeze

  # Logged as a marker so the change is visible but the value never is
  SENSITIVE_MARKERS = { "encrypted_password" => "password" }.freeze

  included do
    class_attribute :auditing_enabled, instance_writer: false, default: true
    class_attribute :audit_ignored_columns, instance_writer: false, default: BASE_IGNORED_COLUMNS

    has_many :audits, -> { order(created_at: :desc) },
             as: :auditable, inverse_of: :auditable, dependent: nil

    after_create_commit  { record_audit(:create) }
    after_update_commit  { record_audit(:update) }
    after_destroy_commit { record_audit(:destroy) }
  end

  # Human label stored alongside the audit so history survives deletion.
  def audit_label
    LABEL_METHODS.each do |method|
      value = try(method)
      return value.to_s.truncate(120) if value.present?
    end

    "#{self.class.model_name.human} ##{id}"
  end

  private

  def record_audit(action)
    return unless self.class.auditing_enabled

    changes = audited_change_set(action)
    return if action == :update && changes.empty?

    Audit.create!(
      auditable_type: self.class.polymorphic_name,
      auditable_id: id,
      action: action.to_s,
      user_id: Current.user&.id,
      user_label: Current.actor_label,
      record_label: audit_label,
      audited_changes: changes,
      ip_address: Current.ip_address,
      request_uuid: Current.request_uuid
    )
  rescue StandardError => e
    # An audit must never take down the request that triggered it
    Rails.logger.error("[audit] #{action} failed for #{self.class.name}##{id}: #{e.class} #{e.message}")
  end

  # Always stored as { "column" => [from, to] } so rendering is uniform.
  def audited_change_set(action)
    case action
    when :create
      snapshot.transform_values { |value| [nil, value] }
    when :destroy
      snapshot.transform_values { |value| [value, nil] }
    else
      saved_changes.except(*audit_ignored_columns).merge(sensitive_markers)
    end
  end

  def sensitive_markers
    SENSITIVE_MARKERS.filter_map do |column, label|
      [label, [nil, "Changed"]] if saved_changes.key?(column)
    end.to_h
  end

  def snapshot
    attributes.except(*audit_ignored_columns).compact
  end
end
