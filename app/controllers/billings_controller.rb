class BillingsController < ApplicationController
  before_action -> { authorize!(:view_billings) }

  def index
    @projects = scoped_projects
      .includes(:project_billings, :main_developer, :call_developer)
      .order(:name)

    @projects = @projects.where(billing_type: params[:billing_type]) if params[:billing_type].present?
    @projects = @projects.where(status: params[:status]) if params[:status].present?

    case params[:billing_status]
    when "draft"
      @projects = @projects.joins(:project_billings).where(project_billings: { status: :draft }).distinct
    when "pending"
      @projects = @projects.joins(:project_billings).where(project_billings: { status: :pending }).distinct
    when "open"
      @projects = @projects.joins(:project_billings).where(project_billings: { status: [:draft, :pending] }).distinct
    when "cleared"
      @projects = @projects.joins(:project_billings).where(project_billings: { status: :cleared }).distinct
    when "no_entries"
      @projects = @projects.left_outer_joins(:project_billings).where(project_billings: { id: nil })
    end

    billings = ProjectBilling.where(project_id: @projects.select(:id))
    @overview = {
      projects: @projects.size,
      draft_entries: billings.draft.count,
      pending_entries: billings.pending.count,
      open_entries: billings.open.count,
      cleared_entries: billings.cleared.count,
      pending_hours: billings.open.sum(:hours_billed).to_f,
      cleared_hours: billings.cleared.sum(:hours_billed).to_f,
      pending_amount: billings.open.sum(:amount).to_f,
      cleared_amount: billings.cleared.sum(:amount).to_f,
      this_month_open: billings.open.for_month(Date.current).count
    }

    @recent_pending = billings.open.includes(:project).ordered.limit(12)
  end
end
