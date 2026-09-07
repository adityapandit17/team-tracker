class IncentivesController < ApplicationController
  before_action -> { authorize!(:view_incentives) }
  before_action :set_developer, only: [:show]
  before_action :authorize_incentive_access!, only: [:show]

  def index
    developers = scoped_incentive_developers
      .includes(:led_projects)
      .order(:name)

    developers = developers.incentive_eligible_leads if params[:eligible] == "1"
    developers = developers.with_led_projects if params[:with_projects] == "1"

    @report = LeadIncentiveReport.new(developers: developers)
    @totals = @report.totals
  end

  def show
    @summary = LeadIncentiveReport.for_developer(@developer)
  end

  private

  def set_developer
    @developer = Developer.find(params[:id])
  end

  def authorize_incentive_access!
    authorize_record!(@developer)
  end

  def scoped_incentive_developers
    base = scoped_developers
    # Leads: anyone marked incentive-eligible or currently assigned as a project lead
    base.where(
      "developers.incentive_eligible = TRUE OR developers.id IN (?)",
      Project.where.not(lead_developer_id: nil).select(:lead_developer_id)
    )
  end
end
