class OneOnOne < ApplicationRecord
  STATUSES = {
    scheduled: "scheduled",
    completed: "completed",
    cancelled: "cancelled"
  }.freeze

  belongs_to :developer
  belongs_to :conductor, class_name: "User"
  belongs_to :growth_plan, optional: true
  belongs_to :assessment, optional: true

  has_many :action_items, dependent: :nullify

  enum :status, STATUSES, default: "scheduled"

  validates :meeting_on, presence: true
  validates :status, presence: true

  scope :upcoming, -> { where("meeting_on >= ?", Date.current).where.not(status: "cancelled").order(:meeting_on) }
  scope :past, -> { where("meeting_on < ?", Date.current).order(meeting_on: :desc) }
  scope :review_due, ->(on = Date.current) {
    where.not(status: "cancelled").where("next_review_on IS NOT NULL AND next_review_on <= ?", on)
  }
  scope :ordered, -> { order(meeting_on: :desc, id: :desc) }

  def overdue_review?
    next_review_on.present? && next_review_on < Date.current && !cancelled?
  end

  # Create linked action items from newline-separated titles (used after save).
  def create_action_items_from_lines!(lines, created_by:)
    Array(lines).map(&:to_s).map(&:strip).reject(&:blank?).each_with_index do |title, index|
      action_items.create!(
        title: title,
        developer: developer,
        assignee: developer.user || created_by,
        created_by: created_by,
        growth_plan: growth_plan,
        status: "todo",
        priority: "medium",
        due_on: next_review_on,
        position: index
      )
    end
  end
end
