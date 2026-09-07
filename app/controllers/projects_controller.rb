class ProjectsController < ApplicationController
  # Fields that can be edited straight from the projects table
  CELL_FIELDS = %w[
    name technology start_date billing_type status
    call_developer_id main_developer_id lead_developer_id
  ].freeze

  before_action :set_project, only: [:show, :edit, :update, :destroy, :update_cell]
  before_action -> { authorize!(:manage_all_records) }, only: [:new, :create, :destroy]
  before_action :authorize_project_access!, only: [:show, :edit, :update, :update_cell]
  before_action -> { authorize!(:edit_own_projects) }, only: [:edit, :update, :update_cell]

  def index
    @projects = scoped_projects
      .includes(:call_developer, :main_developer, :helper_developer, :lead_developer, :project_billings)
      .order(:name)
    @projects = @projects.where(status: params[:status]) if params[:status].present?
    @projects = @projects.where(billing_type: params[:billing_type]) if params[:billing_type].present?
  end

  def show
    @summary = @project.billing_summary
    @recent_billings = @project.project_billings.ordered.limit(6)
    @allocations = @project.allocations.active_on.includes(:developer).ordered
    @timeline = ProjectTimeline.new(@project)
  end

  def new
    @project = Project.new(start_date: Date.current, billing_type: :monthly)
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      @project.ensure_billing_periods!
      redirect_to @project, notice: "Project created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      @project.ensure_billing_periods! if can?(:manage_billings)
      redirect_to @project, notice: "Project updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Project removed."
  end

  def update_cell
    field = params[:field].to_s

    unless editable_cell_fields.include?(field)
      return render_cell_result(alert: "You cannot edit that field.")
    end

    if @project.update(field => cell_value(field))
      @project.ensure_billing_periods! if can?(:manage_billings) && %w[start_date billing_type].include?(field)
      render_cell_result(notice: "#{@project.name} · #{field.humanize.downcase} saved.")
    else
      message = @project.errors.full_messages.to_sentence
      @project.reload
      render_cell_result(alert: message.presence || "Could not save that change.")
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def authorize_project_access!
    authorize_record!(@project)
  end

  def project_params
    if can?(:manage_all_records)
      params.require(:project).permit(
        :name, :status, :technology, :start_date, :billing_type, :fixed_amount, :hourly_rate,
        :call_developer_id, :main_developer_id, :helper_developer_id, :lead_developer_id, :incentive_eligible
      )
    else
      params.require(:project).permit(:status)
    end
  end

  def editable_cell_fields
    fields = can?(:manage_all_records) ? CELL_FIELDS.dup : %w[status]
    fields << "incentive_eligible" if can?(:manage_incentives)
    fields
  end

  def cell_value(field)
    raw = params[:value]

    case field
    when "incentive_eligible" then ActiveModel::Type::Boolean.new.cast(raw)
    when "name" then raw.to_s.strip
    when *CELL_FIELDS.grep(/_id\z/), "start_date" then raw.presence
    else raw
    end
  end

  def render_cell_result(notice: nil, alert: nil)
    @cell_notice = notice
    @cell_alert = alert

    respond_to do |format|
      format.turbo_stream { render :update_cell }
      format.html { redirect_to projects_path, notice: notice, alert: alert }
    end
  end
end
