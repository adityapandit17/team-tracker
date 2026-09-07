# Calculates fixed lead incentives:
# eligible projects under a lead, minus free threshold, times amount per project.
#
# Example: 5 eligible projects, free_project_count=2, amount=1000
# → incentive for 3 projects → ₹3,000
class LeadIncentiveReport
  HANDLED_STATUSES = %w[active hold].freeze

  Row = Struct.new(
    :developer,
    :total_led_projects,
    :eligible_projects,
    :free_threshold,
    :incentive_project_count,
    :amount_per_project,
    :total_amount,
    :lead_eligible,
    :projects,
    keyword_init: true
  )

  ProjectRow = Struct.new(
    :project,
    :eligible,
    :counts_toward_incentive,
    :within_free_threshold,
    keyword_init: true
  )

  def initialize(developers:)
    @developers = Array(developers)
  end

  def rows
    @rows ||= @developers.map { |developer| build_row(developer) }
  end

  def totals
    {
      leads: rows.size,
      total_led_projects: rows.sum(&:total_led_projects),
      eligible_projects: rows.sum { |r| r.eligible_projects.size },
      incentive_projects: rows.sum(&:incentive_project_count),
      total_amount: rows.sum { |r| r.total_amount.to_f }
    }
  end

  def self.for_developer(developer)
    new(developers: [developer]).rows.first
  end

  private

  def build_row(developer)
    led = developer.led_projects
      .where(status: HANDLED_STATUSES)
      .order(Arel.sql("start_date ASC NULLS LAST"), :id)
      .to_a

    lead_eligible = developer.incentive_eligible?
    free = [developer.incentive_free_project_count.to_i, 0].max
    rate = developer.incentive_amount_per_project

    eligible = led.select { |p| lead_eligible && p.incentive_eligible? }
    incentive_count = [eligible.size - free, 0].max
    amount = lead_eligible && rate.present? ? incentive_count * rate.to_f : 0.0

    project_rows = led.map do |project|
      is_eligible = lead_eligible && project.incentive_eligible?
      index_in_eligible = is_eligible ? eligible.index(project) : nil
      within_free = is_eligible && index_in_eligible && index_in_eligible < free
      counts = is_eligible && index_in_eligible && index_in_eligible >= free

      ProjectRow.new(
        project: project,
        eligible: is_eligible,
        counts_toward_incentive: counts,
        within_free_threshold: within_free
      )
    end

    Row.new(
      developer: developer,
      total_led_projects: led.size,
      eligible_projects: eligible,
      free_threshold: free,
      incentive_project_count: incentive_count,
      amount_per_project: rate,
      total_amount: amount,
      lead_eligible: lead_eligible,
      projects: project_rows
    )
  end
end
