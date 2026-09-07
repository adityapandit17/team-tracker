class Audit < ApplicationRecord
  # The audit trail never audits itself
  self.auditing_enabled = false

  ACTIONS = %w[create update destroy].freeze

  Entry = Struct.new(:field, :label, :from, :to, keyword_init: true)

  belongs_to :auditable, polymorphic: true, optional: true
  belongs_to :user, optional: true

  validates :action, inclusion: { in: ACTIONS }

  scope :recent, -> { order(created_at: :desc) }
  scope :for_record, ->(record) {
    where(auditable_type: record.class.polymorphic_name, auditable_id: record.id)
  }
  scope :search, ->(term) {
    where("record_label ILIKE :q OR user_label ILIKE :q", q: "%#{sanitize_sql_like(term.to_s)}%")
  }

  def actor
    user_label.presence || "System"
  end

  def record_name
    record_label.presence || "#{auditable_type} ##{auditable_id}"
  end

  def type_label
    auditable_type.to_s.underscore.humanize
  end

  def entries
    audited_changes.map do |field, value|
      from, to = value.is_a?(Array) ? value : [nil, value]

      Entry.new(
        field: field,
        label: field.to_s.delete_suffix("_id").humanize,
        from: display_value(field, from),
        to: display_value(field, to)
      )
    end
  end

  private

  def display_value(field, value)
    case value
    when nil, "" then nil
    when true then "Yes"
    when false then "No"
    else field.end_with?("_id") ? associated_label(field, value) : value
    end
  end

  def associated_label(field, value)
    reflection = auditable_class&.reflect_on_association(field.delete_suffix("_id").to_sym)
    return "##{value}" if reflection.nil? || reflection.polymorphic?

    self.class.cached_label(reflection.klass, value)
  end

  def auditable_class
    @auditable_class ||= auditable_type.safe_constantize
  end

  # Association lookups repeat heavily on the audit list, so resolve each
  # record once per request.
  def self.cached_label(klass, id)
    cache = (Current.audit_labels ||= {})

    cache.fetch([klass.name, id]) do
      record = klass.find_by(id: id)
      cache[[klass.name, id]] =
        record ? (record.try(:name) || record.try(:display_name) || record.try(:title) || "##{id}") : "##{id}"
    end
  end
end
