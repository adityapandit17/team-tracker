class Skill < ApplicationRecord
  has_many :developer_skills, dependent: :destroy
  has_many :developers, through: :developer_skills

  validates :name, presence: true, uniqueness: true

  CATEGORIES = ["Frontend", "Backend", "Database", "Cloud / DevOps", "Mobile", "QA / Testing", "AI / ML", "System Design"].freeze
end
