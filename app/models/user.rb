class User < ApplicationRecord
  ROLES = {
    admin: 0,
    manager: 1,
    team_lead: 2,
    developer: 3
  }.freeze

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, ROLES, default: :developer

  belongs_to :developer, optional: true
  has_many :team_developers, class_name: "Developer", foreign_key: :team_lead_id, dependent: :nullify, inverse_of: :team_lead
  has_many :authored_feedbacks, class_name: "Feedback", foreign_key: :author_id, dependent: :destroy, inverse_of: :author
  has_many :authored_assessments, class_name: "Assessment", foreign_key: :author_id, dependent: :destroy, inverse_of: :author
  has_many :assigned_action_items, class_name: "ActionItem", foreign_key: :assignee_id, dependent: :destroy, inverse_of: :assignee
  has_many :created_action_items, class_name: "ActionItem", foreign_key: :created_by_id, dependent: :destroy, inverse_of: :created_by
  has_many :owned_growth_plans, class_name: "GrowthPlan", foreign_key: :owner_id, dependent: :destroy, inverse_of: :owner
  has_many :conducted_one_on_ones, class_name: "OneOnOne", foreign_key: :conductor_id, dependent: :destroy, inverse_of: :conductor

  validates :name, presence: true
  validates :role, presence: true
  validate :developer_required_for_scoped_roles
  validate :developer_link_unique, if: -> { developer_id.present? }

  def staff?
    admin? || manager?
  end

  def scoped?
    team_lead? || developer?
  end

  def display_name
    name.presence || email
  end

  def accessible_developer_ids
    ids = [developer_id].compact
    ids.concat(team_developers.pluck(:id)) if team_lead?
    ids.uniq
  end

  def self.promote_developer!(developer, email:, password: nil, name: nil)
    raise ArgumentError, "Developer required" if developer.blank?

    user = developer.user || find_or_initialize_by(email: email.downcase.strip)
    user.name = name.presence || developer.name
    user.email = email.downcase.strip
    user.developer = developer
    user.role = :team_lead

    if user.new_record? || password.present?
      raise ArgumentError, "Password is required for new accounts" if password.blank?

      user.password = password
      user.password_confirmation = password
    end

    ActiveRecord::Base.transaction do
      user.save!
      developer.update!(team_lead_id: nil) if developer.team_lead_id.present?
    end

    user
  end

  def demote_to_developer!(assign_to_lead: nil)
    raise ArgumentError, "Only team leads can be demoted" unless team_lead?

    ActiveRecord::Base.transaction do
      team_developers.update_all(team_lead_id: nil)
      update!(role: :developer)
      developer&.update!(team_lead: assign_to_lead) if assign_to_lead.present?
    end
    self
  end

  private

  def developer_required_for_scoped_roles
    return unless scoped?
    return if developer_id.present?

    errors.add(:developer, "must be linked for team leads and developers")
  end

  def developer_link_unique
    other = User.where(developer_id: developer_id).where.not(id: id)
    return unless other.exists?

    errors.add(:developer, "is already linked to another user account")
  end
end
