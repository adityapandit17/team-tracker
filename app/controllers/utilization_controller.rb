class UtilizationController < ApplicationController
  before_action -> { authorize!(:view_utilization) }

  def index
    @month = if params[:month].present?
      Date.parse("#{params[:month]}-01")
    else
      Date.current.beginning_of_month
    end

    developers = scoped_developers.includes(:allocations).order(:name)
    projects = scoped_projects.includes(:allocations, :project_billings).order(:name)
    @report = UtilizationReport.new(developers: developers, projects: projects, month: @month)
    @totals = @report.totals
  end
end
