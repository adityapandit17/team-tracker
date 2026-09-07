class GrowthPlansController < ApplicationController
  before_action :set_developer, only: %i[index new create], if: -> { params[:developer_id].present? }
  before_action :set_growth_plan, only: %i[show edit update destroy]
  before_action :authorize_manage!, only: %i[new create edit update destroy]
  before_action :authorize_access!, only: %i[show edit update destroy]

  def index
    @growth_plans = if @developer
      authorize_record!(@developer)
      return if performed?

      @developer.growth_plans.includes(:owner, :assessment).ordered
    else
      scoped_growth_plans.includes(:developer, :owner, :assessment).ordered
    end
    @growth_plans = @growth_plans.where(status: params[:status]) if params[:status].present?
  end

  def show
    @one_on_ones = @growth_plan.one_on_ones.ordered.limit(10)
    @action_items = @growth_plan.action_items.includes(:assignee).ordered
  end

  def new
    @growth_plan = GrowthPlan.new(
      developer: @developer,
      status: "active",
      next_review_on: Date.current + 30.days,
      target_career_level: "mid",
      title: @developer ? "#{@developer.name} growth plan" : nil
    )
  end

  def create
    @growth_plan = GrowthPlan.new(growth_plan_params)
    @growth_plan.owner = current_user
    @growth_plan.developer ||= @developer

    authorize_record!(@growth_plan.developer)
    return if performed?

    if @growth_plan.save
      redirect_to(@developer ? developer_path(@developer) : @growth_plan, notice: "Growth plan created.")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @growth_plan.update(growth_plan_params)
      redirect_to @growth_plan, notice: "Growth plan updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @growth_plan.destroy
    redirect_to growth_plans_path, notice: "Growth plan removed."
  end

  private

  def set_developer
    @developer = Developer.find(params[:developer_id])
  end

  def set_growth_plan
    @growth_plan = GrowthPlan.find(params[:id])
  end

  def authorize_manage!
    authorize!(:manage_growth_plans)
  end

  def authorize_access!
    authorize_record!(@growth_plan)
  end

  def growth_plan_params
    params.require(:growth_plan).permit(
      :developer_id, :assessment_id, :title, :target_career_level,
      :goals, :focus_areas, :next_review_on, :status
    )
  end
end
