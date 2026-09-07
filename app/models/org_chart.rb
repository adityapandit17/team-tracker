# Reporting hierarchy: ops leadership -> team leads -> their developers.
#
# The only reporting FK in the schema is developers.team_lead_id, so leads are
# grouped under the leadership band rather than under one specific manager.
class OrgChart
  LEADERSHIP_KEY = "leadership".freeze
  UNASSIGNED_KEY = "unassigned".freeze

  Actor = Struct.new(:key, :parent_key, :name, :role, :subtitle, :developer, :user, :report_count, :project_count, :led_count, keyword_init: true) do
    def developer_id = developer&.id
    def account_role = user&.role
    def initials_name = name
  end

  def leadership
    @leadership ||= User.where(role: [:admin, :manager]).order(:role, :name).map do |user|
      Actor.new(
        key: "user-#{user.id}",
        parent_key: nil,
        name: user.display_name,
        role: user.role,
        subtitle: user.email,
        user: user,
        developer: user.developer
      )
    end
  end

  def leads
    @leads ||= User.team_lead.includes(:developer).order(:name).map do |user|
      Actor.new(
        key: "user-#{user.id}",
        parent_key: LEADERSHIP_KEY,
        name: user.display_name,
        role: user.role,
        subtitle: user.developer&.stack&.upcase,
        user: user,
        developer: user.developer,
        report_count: reports_for(user).size,
        project_count: user.developer && project_counts[user.developer.id].to_i,
        led_count: user.developer && led_counts[user.developer.id].to_i
      )
    end
  end

  def reports_for(lead)
    reports_by_lead.fetch(lead.id, [])
  end

  # Developers with no lead, excluding people already drawn as leads
  def unassigned
    @unassigned ||= developers.select { |d| d.team_lead_id.nil? && !lead_developer_ids.include?(d.id) }
                              .map { |developer| build_developer_actor(developer, UNASSIGNED_KEY) }
  end

  def totals
    {
      leadership: leadership.size,
      leads: leads.size,
      developers: developers.size - lead_developer_ids.size,
      unassigned: unassigned.size
    }
  end

  private

  def developers
    @developers ||= Developer.includes(:user).order(:name).to_a
  end

  def reports_by_lead
    @reports_by_lead ||= developers
      .reject { |d| lead_developer_ids.include?(d.id) }
      .select(&:team_lead_id)
      .group_by(&:team_lead_id)
      .transform_values { |list| list.map { |d| build_developer_actor(d, "user-#{d.team_lead_id}") } }
  end

  def build_developer_actor(developer, parent_key)
    Actor.new(
      key: "dev-#{developer.id}",
      parent_key: parent_key,
      name: developer.name,
      role: developer.user&.role || "developer",
      subtitle: developer.stack.upcase,
      developer: developer,
      user: developer.user,
      project_count: project_counts[developer.id].to_i,
      led_count: led_counts[developer.id].to_i
    )
  end

  def lead_developer_ids
    @lead_developer_ids ||= User.team_lead.where.not(developer_id: nil).pluck(:developer_id).to_set
  end

  # One pass over projects instead of a count query per person
  def project_counts
    @project_counts ||= begin
      buckets = Hash.new { |hash, key| hash[key] = Set.new }
      Project.pluck(:id, :main_developer_id, :helper_developer_id).each do |id, main, helper|
        buckets[main] << id if main
        buckets[helper] << id if helper
      end
      buckets.transform_values(&:size)
    end
  end

  def led_counts
    @led_counts ||= Project.where.not(lead_developer_id: nil).group(:lead_developer_id).count
  end
end
