class AssessmentCriterion < ApplicationRecord
  self.table_name = "assessment_criteria"

  belongs_to :assessment, inverse_of: :assessment_criteria

  validates :name, presence: true
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
