class Developer < ApplicationRecord
  enum :stack, { ror: "ror", mern: "mern", other: "other" }, default: "other"
  enum :availability_status, { available: "available", unavailable: "not_available" }, default: "available"

  belongs_to :team_lead, class_name: "User", optional: true

  has_many :developer_skills, dependent: :destroy
  has_many :skills, through: :developer_skills

  has_many :main_projects, class_name: "Project", foreign_key: :main_developer_id, dependent: :nullify
  has_many :helper_projects, class_name: "Project", foreign_key: :helper_developer_id, dependent: :nullify
  has_many :call_projects, class_name: "Project", foreign_key: :call_developer_id, dependent: :nullify
  has_many :led_projects, class_name: "Project", foreign_key: :lead_developer_id, dependent: :nullify

  has_many :client_leads, foreign_key: :assignee_id, dependent: :nullify, inverse_of: :assignee
  has_many :feedbacks, dependent: :destroy
  has_many :assessments, dependent: :destroy
  has_many :action_items, dependent: :nullify
  has_many :growth_plans, dependent: :destroy
  has_many :one_on_ones, dependent: :destroy
  has_many :allocations, dependent: :destroy
  has_one :user, dependent: :nullify

  validates :name, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true
  validates :hourly_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :incentive_free_project_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :incentive_amount_per_project, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :team_lead_must_be_team_lead_role

  scope :incentive_eligible_leads, -> { where(incentive_eligible: true) }
  scope :with_led_projects, -> { where(id: Project.where.not(lead_developer_id: nil).select(:lead_developer_id)) }

  BENCH_THRESHOLD_PCT = 50

  LEAD_STATUS_COLORS = {
    "won" => "#c6efce",
    "active" => "#ddebf7",
    "hold" => "#ffeb9c",
    "lost" => "#ffc7ce"
  }.freeze

  def project_count
    (main_projects + helper_projects).map(&:id).uniq.count
  end

  def led_project_count
    led_projects.where(status: LeadIncentiveReport::HANDLED_STATUSES).count
  end

  def incentive_summary
    LeadIncentiveReport.for_developer(self)
  end

  def initials
    name.gsub(/\(.*?\)/, "").strip.split(" ").map { |p| p[0] }.first(2).join.upcase
  end

  def team_lead_account?
    user&.team_lead?
  end

  def current_allocations(date = Date.current)
    allocations.active_on(date).includes(:project)
  end

  def current_allocation_pct(date = Date.current)
    current_allocations(date).sum(:allocation_pct)
  end

  def on_bench?(date = Date.current)
    current_allocation_pct(date) < BENCH_THRESHOLD_PCT
  end

  def allocated_hours(date = Date.current)
    current_allocations(date).sum { |a| a.allocated_hours }
  end

  def active_growth_plan
    growth_plans.active_plans.ordered.first
  end

  def lead_report
    leads = client_leads
    by_status = ClientLead.statuses.keys.index_with { |s| 0 }.merge(leads.group(:status).count)
    total = leads.count
    won = by_status["won"] || 0
    lost = by_status["lost"] || 0
    decided = won + lost

    {
      total: total,
      by_status: by_status,
      won: won,
      lost: lost,
      active: by_status["active"] || 0,
      hold: by_status["hold"] || 0,
      open: (by_status["active"] || 0) + (by_status["hold"] || 0),
      win_rate: decided.zero? ? nil : ((won * 100.0) / decided).round(1),
      conversion_rate: total.zero? ? 0.0 : ((won * 100.0) / total).round(1),
      avg_rounds: leads.average(:rounds)&.to_f&.round(1),
      chart_labels: ClientLead.statuses.keys.map(&:humanize),
      chart_values: ClientLead.statuses.keys.map { |s| by_status[s] || 0 },
      chart_colors: ClientLead.statuses.keys.map { |s| LEAD_STATUS_COLORS[s] }
    }
  end

  private

  def team_lead_must_be_team_lead_role
    return if team_lead.blank?
    return if team_lead.team_lead?

    errors.add(:team_lead, "must be a user with the team lead role")
  end
end
