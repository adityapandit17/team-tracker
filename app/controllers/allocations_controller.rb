class AllocationsController < ApplicationController
  before_action :set_developer, only: %i[index new create], if: -> { params[:developer_id].present? }
  before_action :set_project, only: %i[index new create], if: -> { params[:project_id].present? && params[:developer_id].blank? }
  before_action :set_allocation, only: %i[show edit update destroy]
  before_action :authorize_manage!, only: %i[new create edit update destroy]
  before_action :authorize_access!, only: %i[show edit update destroy]

  def index
    @allocations = if @developer
      authorize_record!(@developer)
      return if performed?

      @developer.allocations.includes(:project).ordered
    elsif @project
      authorize_record!(@project)
      return if performed?

      @project.allocations.includes(:developer).ordered
    else
      scoped_allocations.includes(:developer, :project).ordered
    end
    @allocations = @allocations.active_on(Date.current) if params[:active] == "1"
  end

  def bench
    authorize!(:manage_allocations)
    @as_of = params[:as_of].present? ? Date.parse(params[:as_of]) : Date.current
    developers = scoped_developers.includes(:allocations, :team_lead).order(:name)
    @bench = []
    @allocated = []

    developers.each do |dev|
      pct = dev.current_allocation_pct(@as_of)
      row = { developer: dev, pct: pct, hours: dev.allocated_hours(@as_of), allocations: dev.current_allocations(@as_of) }
      if pct < Developer::BENCH_THRESHOLD_PCT
        @bench << row
      else
        @allocated << row
      end
    end
  end

  def show
  end

  def new
    @allocation = Allocation.new(
      developer: @developer,
      project: @project,
      start_on: Date.current.beginning_of_month,
      allocation_pct: 100,
      role: "main"
    )
  end

  def create
    @allocation = Allocation.new(allocation_params)
    @allocation.developer ||= @developer
    @allocation.project ||= @project

    authorize_record!(@allocation.developer)
    return if performed?

    if @allocation.save
      redirect_after_save("Allocation added.")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @allocation.update(allocation_params)
      redirect_to allocations_path(active: "1"), notice: "Allocation updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @allocation.destroy
    redirect_to allocations_path, notice: "Allocation removed."
  end

  private

  def set_developer
    @developer = Developer.find(params[:developer_id])
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_allocation
    @allocation = Allocation.find(params[:id])
  end

  def authorize_manage!
    authorize!(:manage_allocations)
  end

  def authorize_access!
    authorize_record!(@allocation)
  end

  def redirect_after_save(notice)
    if @developer
      redirect_to developer_path(@developer), notice: notice
    elsif @project
      redirect_to project_path(@project), notice: notice
    else
      redirect_to bench_path, notice: notice
    end
  end

  def allocation_params
    params.require(:allocation).permit(
      :developer_id, :project_id, :role, :allocation_pct, :start_on, :end_on, :notes
    )
  end
end
