class DeveloperSkill < ApplicationRecord
  enum :proficiency, { na: "na", beginner: "beginner", intermediate: "intermediate", advanced: "advanced", expert: "expert" },
       default: "na"

  belongs_to :developer
  belongs_to :skill

  validates :developer_id, uniqueness: { scope: :skill_id }
end
