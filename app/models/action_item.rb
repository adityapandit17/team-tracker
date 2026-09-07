class ActionItem < ApplicationRecord
  STATUSES = {
    todo: "todo",
    in_progress: "in_progress",
    done: "done"
  }.freeze

  PRIORITIES = {
    low: "low",
    medium: "medium",
    high: "high"
  }.freeze

  belongs_to :developer, optional: true
  belongs_to :assignee, class_name: "User"
  belongs_to :created_by, class_name: "User"
  belongs_to :one_on_one, optional: true
  belongs_to :growth_plan, optional: true

  enum :status, STATUSES, default: "todo"
  enum :priority, PRIORITIES, default: "medium"

  validates :title, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :open_items, -> { where.not(status: "done") }
  scope :personal, -> { where(developer_id: nil) }
  scope :for_developer, ->(developer_id) { where(developer_id: developer_id) }
  scope :ordered, -> { order(:position, :due_on, :id) }

  def personal?
    developer_id.nil?
  end
end
