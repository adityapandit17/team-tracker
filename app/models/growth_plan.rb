class GrowthPlan < ApplicationRecord
  STATUSES = {
    active: "active",
    paused: "paused",
    completed: "completed"
  }.freeze

  belongs_to :developer
  belongs_to :owner, class_name: "User"
  belongs_to :assessment, optional: true

  has_many :one_on_ones, dependent: :nullify
  has_many :action_items, dependent: :nullify

  enum :status, STATUSES, default: "active"

  validates :title, presence: true
  validates :status, presence: true
  validates :target_career_level, inclusion: { in: Assessment::CAREER_LEVELS.values }, allow_blank: true

  scope :active_plans, -> { where(status: "active") }
  scope :review_due, ->(on = Date.current) { active_plans.where("next_review_on IS NOT NULL AND next_review_on <= ?", on) }
  scope :ordered, -> { order(Arel.sql("next_review_on ASC NULLS LAST"), :title) }

  def overdue?
    next_review_on.present? && next_review_on < Date.current && active?
  end
end
