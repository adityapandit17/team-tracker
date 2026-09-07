class Feedback < ApplicationRecord
  belongs_to :developer
  belongs_to :author, class_name: "User"

  validates :title, presence: true
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :feedback_date, presence: true
end
