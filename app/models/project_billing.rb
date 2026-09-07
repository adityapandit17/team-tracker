class ProjectBilling < ApplicationRecord
  attribute :status, :string

  # draft   = auto-created at month end, awaiting hours
  # pending = submitted / ready for clearance
  # cleared = billing settled
  enum :status, { draft: "draft", pending: "pending", cleared: "cleared" }, default: "draft"

  belongs_to :project

  validates :billing_month, presence: true
  validates :billing_month, uniqueness: { scope: :project_id, message: "already has a billing entry for this project" }
  validates :hours_billed, numericality: { greater_than_or_equal_to: 0 }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :status, presence: true
  validate :billing_month_must_be_month_start

  before_validation :normalize_billing_month

  scope :ordered, -> { order(billing_month: :desc) }
  scope :for_month, ->(date) { where(billing_month: date.to_date.beginning_of_month) }
  scope :open, -> { where(status: [:draft, :pending]) }

  def month_label
    billing_month.strftime("%B %Y")
  end

  def open?
    draft? || pending?
  end

  def audit_label
    [project&.name, billing_month && month_label].compact.join(" · ").presence || super
  end

  private

  def normalize_billing_month
    return if billing_month.blank?

    self.billing_month = billing_month.to_date.beginning_of_month
  end

  def billing_month_must_be_month_start
    return if billing_month.blank?
    return if billing_month.day == 1

    errors.add(:billing_month, "must be the first day of the month")
  end
end
