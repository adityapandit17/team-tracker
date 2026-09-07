class Assessment < ApplicationRecord
  CAREER_LEVELS = {
    junior: "junior",
    mid: "mid",
    senior: "senior",
    lead: "lead"
  }.freeze

  DEFAULT_CRITERIA = [
    "Communication",
    "Code quality",
    "Ownership",
    "Delivery",
    "Collaboration"
  ].freeze

  belongs_to :developer
  belongs_to :author, class_name: "User"
  has_many :assessment_criteria, -> { order(:position, :id) }, class_name: "AssessmentCriterion", dependent: :destroy, inverse_of: :assessment

  accepts_nested_attributes_for :assessment_criteria, allow_destroy: true, reject_if: proc { |attrs| attrs["name"].blank? }

  enum :career_level, CAREER_LEVELS, default: "mid"

  validates :title, presence: true
  validates :career_level, presence: true
  validates :assessed_on, presence: true
  validates :assessment_criteria, length: { minimum: 1, message: "must include at least one criterion" }

  before_validation :recalculate_overall_rating

  def self.build_with_defaults(attrs = {})
    assessment = new(attrs)
    DEFAULT_CRITERIA.each_with_index do |name, index|
      assessment.assessment_criteria.build(name: name, rating: 3, position: index)
    end
    assessment
  end

  def recalculate_overall_rating
    ratings = assessment_criteria.reject(&:marked_for_destruction?).map(&:rating).compact
    self.overall_rating = ratings.any? ? (ratings.sum.to_f / ratings.size).round(2) : nil
  end
end
