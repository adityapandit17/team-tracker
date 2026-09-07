class Project < ApplicationRecord
  # Explicit types so enums work even if schema cache is briefly stale after migrate
  attribute :status, :string
  attribute :billing_type, :string

  enum :status, { active: "active", hold: "hold", completed: "completed" }, default: "active"
  enum :billing_type, { monthly: "monthly", fixed_price: "fixed_price" }, default: "monthly"

  belongs_to :call_developer, class_name: "Developer", optional: true
  belongs_to :main_developer, class_name: "Developer", optional: true
  belongs_to :helper_developer, class_name: "Developer", optional: true
  belongs_to :lead_developer, class_name: "Developer", optional: true

  has_many :project_billings, dependent: :destroy, inverse_of: :project
  has_many :allocations, dependent: :destroy

  validates :name, presence: true
  validates :fixed_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :hourly_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :fixed_amount_required_for_fixed_price

  scope :billable_monthly, -> {
    monthly.where(status: [:active, :hold]).where.not(start_date: nil)
  }
  scope :incentive_eligible, -> { where(incentive_eligible: true) }
  scope :with_lead, -> { where.not(lead_developer_id: nil) }

  def billing_summary
    billings = project_billings
    {
      total_entries: billings.count,
      draft_count: billings.draft.count,
      pending_count: billings.pending.count,
      cleared_count: billings.cleared.count,
      total_hours: billings.sum(:hours_billed).to_f,
      pending_hours: billings.where(status: [:draft, :pending]).sum(:hours_billed).to_f,
      cleared_hours: billings.cleared.sum(:hours_billed).to_f,
      total_amount: billings.sum(:amount).to_f,
      pending_amount: billings.where(status: [:draft, :pending]).sum(:amount).to_f,
      cleared_amount: billings.cleared.sum(:amount).to_f,
      latest: billings.ordered.first
    }
  end

  # Ensure monthly stubs exist from start_date through current month (or fixed: one entry)
  def ensure_billing_periods!(through: Date.current)
    return if start_date.blank?

    if fixed_price?
      month = start_date.beginning_of_month
      project_billings.find_or_create_by!(billing_month: month) do |b|
        b.hours_billed = 0
        b.amount = fixed_amount
        b.status = :draft
        b.notes = "Fixed price billing draft"
      end
    else
      cursor = start_date.beginning_of_month
      last = through.to_date.beginning_of_month
      while cursor <= last
        create_draft_billing_for!(cursor)
        cursor = cursor.next_month
      end
    end
  end

  def create_draft_billing_for!(month)
    month = month.to_date.beginning_of_month
    return nil if start_date.blank?
    return nil if month < start_date.beginning_of_month
    return nil unless monthly?

    billing = project_billings.find_or_initialize_by(billing_month: month)
    return billing unless billing.new_record?

    billing.assign_attributes(
      hours_billed: 0,
      status: :draft,
      notes: "Auto-created draft at month end"
    )
    billing.save!
    billing
  end

  # Creates draft billings for all eligible monthly projects for a given month.
  # Returns counts for logging / job results.
  def self.create_monthly_draft_billings!(billing_month:)
    month = billing_month.to_date.beginning_of_month
    created = 0
    skipped = 0
    considered = 0

    billable_monthly.find_each do |project|
      next if project.start_date.beginning_of_month > month

      considered += 1
      existing = project.project_billings.find_by(billing_month: month)
      if existing
        skipped += 1
        next
      end

      project.create_draft_billing_for!(month)
      created += 1
    end

    { billing_month: month, created: created, skipped: skipped, considered: considered }
  end

  private

  def fixed_amount_required_for_fixed_price
    return unless fixed_price?
    return if fixed_amount.present?

    errors.add(:fixed_amount, "is required for fixed price projects")
  end
end
