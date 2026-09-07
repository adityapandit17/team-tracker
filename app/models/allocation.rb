class Allocation < ApplicationRecord
  ROLES = {
    main: "main",
    helper: "helper",
    call: "call",
    support: "support"
  }.freeze

  STANDARD_MONTHLY_HOURS = 160

  belongs_to :developer
  belongs_to :project

  enum :role, ROLES, default: "main"

  validates :allocation_pct, presence: true,
            numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }
  validates :start_on, presence: true
  validates :role, presence: true
  validate :end_on_after_start_on

  scope :ordered, -> { order(start_on: :desc, id: :desc) }
  scope :active_on, ->(date = Date.current) {
    where("start_on <= ?", date)
      .where("end_on IS NULL OR end_on >= ?", date)
  }
  scope :overlapping, ->(range_start, range_end) {
    where("start_on <= ?", range_end)
      .where("end_on IS NULL OR end_on >= ?", range_start)
  }

  def active?(date = Date.current)
    start_on <= date && (end_on.nil? || end_on >= date)
  end

  def allocated_hours(monthly_hours: STANDARD_MONTHLY_HOURS)
    (allocation_pct / 100.0) * monthly_hours
  end

  def audit_label
    [developer&.name, project&.name].compact.join(" · ").presence || super
  end

  private

  def end_on_after_start_on
    return if end_on.blank? || start_on.blank?
    return if end_on >= start_on

    errors.add(:end_on, "must be on or after start date")
  end
end
