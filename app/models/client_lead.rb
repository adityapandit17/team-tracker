class ClientLead < ApplicationRecord
  enum :status, { active: "active", hold: "hold", won: "won", lost: "lost" }, default: "hold"

  belongs_to :assignee, class_name: "Developer", optional: true

  validates :client_name, presence: true
end
