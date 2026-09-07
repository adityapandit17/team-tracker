class UtilizationReport
  STANDARD_HOURS = Allocation::STANDARD_MONTHLY_HOURS

  def initialize(developers:, projects:, month:)
    @developers = developers
    @projects = projects
    @month = month.to_date.beginning_of_month
    @month_end = @month.end_of_month
  end

  def developer_rows
    @developer_rows ||= @developers.map { |dev| build_developer_row(dev) }.sort_by { |r| -r[:allocated_hours] }
  end

  def project_rows
    @project_rows ||= @projects.map { |project| build_project_row(project) }.sort_by { |r| -r[:revenue] }
  end

  def totals
    rows = developer_rows
    allocated = rows.sum { |r| r[:allocated_hours] }
    billed = rows.sum { |r| r[:billed_hours] }
    revenue = project_rows.sum { |r| r[:revenue] }
    cost = project_rows.sum { |r| r[:cost] }
    {
      allocated_hours: allocated.round(1),
      billed_hours: billed.round(1),
      utilization_pct: allocated.zero? ? nil : ((billed / allocated) * 100).round(1),
      revenue: revenue.round(0),
      cost: cost.round(0),
      margin: (revenue - cost).round(0),
      margin_pct: revenue.zero? ? nil : (((revenue - cost) / revenue) * 100).round(1),
      bench_count: rows.count { |r| r[:bench] }
    }
  end

  private

  def billings_by_project
    @billings_by_project ||= ProjectBilling
      .where(project_id: @projects.map(&:id), billing_month: @month)
      .index_by(&:project_id)
  end

  def allocations_in_month
    @allocations_in_month ||= Allocation
      .where(developer_id: @developers.map(&:id))
      .overlapping(@month, @month_end)
      .includes(:developer, :project)
      .to_a
  end

  def build_developer_row(developer)
    allocs = allocations_in_month.select { |a| a.developer_id == developer.id && @projects.map(&:id).include?(a.project_id) }
    allocated_hours = allocs.sum { |a| a.allocated_hours }
    billed_hours = 0.0
    revenue_share = 0.0
    cost = allocated_hours * (developer.hourly_cost || 0).to_f

    allocs.group_by(&:project_id).each do |project_id, project_allocs|
      billing = billings_by_project[project_id]
      next unless billing

      project_total_pct = allocations_in_month.select { |a| a.project_id == project_id }.sum(&:allocation_pct).to_f
      share = project_total_pct.zero? ? 0 : project_allocs.sum(&:allocation_pct) / project_total_pct
      billed_hours += billing.hours_billed.to_f * share
      revenue_share += billing.amount.to_f * share
    end

    {
      developer: developer,
      allocation_pct: allocs.sum(&:allocation_pct),
      allocated_hours: allocated_hours.round(1),
      billed_hours: billed_hours.round(1),
      utilization_pct: allocated_hours.zero? ? nil : ((billed_hours / allocated_hours) * 100).round(1),
      cost: cost.round(0),
      revenue_share: revenue_share.round(0),
      margin: (revenue_share - cost).round(0),
      bench: allocated_hours < (STANDARD_HOURS * Developer::BENCH_THRESHOLD_PCT / 100.0),
      allocations: allocs
    }
  end

  def build_project_row(project)
    allocs = allocations_in_month.select { |a| a.project_id == project.id }
    allocated_hours = allocs.sum { |a| a.allocated_hours }
    billing = billings_by_project[project.id]
    billed_hours = billing&.hours_billed.to_f
    revenue = billing&.amount.to_f
    if revenue.zero? && project.hourly_rate.present? && billed_hours.positive?
      revenue = billed_hours * project.hourly_rate.to_f
    end
    cost = allocs.sum { |a| a.allocated_hours * (a.developer.hourly_cost || 0).to_f }

    {
      project: project,
      allocated_hours: allocated_hours.round(1),
      billed_hours: billed_hours.round(1),
      utilization_pct: allocated_hours.zero? ? nil : ((billed_hours / allocated_hours) * 100).round(1),
      revenue: revenue.round(0),
      cost: cost.round(0),
      margin: (revenue - cost).round(0),
      margin_pct: revenue.zero? ? nil : (((revenue - cost) / revenue) * 100).round(1),
      allocations: allocs
    }
  end
end
