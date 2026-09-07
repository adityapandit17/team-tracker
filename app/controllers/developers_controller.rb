class DevelopersController < ApplicationController
  before_action :set_developer, only: [:show, :edit, :update, :destroy, :promote]
  before_action -> { authorize!(:manage_team_developers) }, only: [:new, :create]
  before_action -> { authorize!(:manage_all_records) }, only: [:destroy]
  before_action -> { authorize!(:promote_team_leads) }, only: [:promote]
  before_action :authorize_developer_access!, only: [:show, :edit, :update]
  before_action :authorize_developer_edit!, only: [:edit, :update]

  def index
    @developers = scoped_developers.includes(:team_lead, :user).order(:name)
    @developers = @developers.where(stack: params[:stack]) if params[:stack].present?
    @developers = @developers.where(ready_for_new_project: true) if params[:ready] == "1"
    @developers = @developers.where(team_lead_id: params[:team_lead_id]) if params[:team_lead_id].present? && can?(:manage_all_records)
  end

  def show
    @skills = @developer.developer_skills.includes(:skill)
    @report = @developer.lead_report
    @assigned_leads = @developer.client_leads.order(updated_at: :desc)
    @projects = (@developer.main_projects + @developer.helper_projects + @developer.call_projects).uniq
    @recent_feedbacks = @developer.feedbacks.includes(:author).order(feedback_date: :desc).limit(5)
    @avg_feedback_rating = @developer.feedbacks.average(:rating)&.to_f&.round(1)
    @latest_assessments = @developer.assessments.includes(:assessment_criteria, :author).order(assessed_on: :desc).limit(3)
    @open_action_items = @developer.action_items.open_items.includes(:assignee).ordered.limit(8)
    @active_growth_plan = @developer.active_growth_plan
    @recent_one_on_ones = @developer.one_on_ones.includes(:conductor).ordered.limit(5)
    @current_allocations = @developer.current_allocations.includes(:project)
    @incentive_summary = @developer.incentive_summary if @developer.led_projects.any? || @developer.incentive_eligible?
  end

  def new
    @developer = Developer.new
    @developer.team_lead = current_user if current_user.team_lead?
  end

  def create
    @developer = Developer.new(developer_params)
    @developer.team_lead = current_user if current_user.team_lead?

    if @developer.save
      redirect_to @developer, notice: "Developer added#{current_user.team_lead? ? " to your team" : ""}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attrs = developer_params
    attrs = attrs.except(:team_lead_id) if current_user.team_lead?

    if @developer.update(attrs)
      redirect_to @developer, notice: "Developer updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @developer.destroy
    redirect_to developers_path, notice: "Developer removed."
  end

  def promote
    user = User.promote_developer!(
      @developer,
      email: params.require(:email),
      password: params[:password].presence,
      name: params[:name].presence
    )
    redirect_to @developer, notice: "#{@developer.name} promoted to team lead (#{user.email})."
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    redirect_to @developer, alert: e.message
  end

  private

  def set_developer
    @developer = Developer.find(params[:id])
  end

  def authorize_developer_access!
    authorize_record!(@developer)
  end

  def authorize_developer_edit!
    return if can?(:manage_all_records)
    return if current_user.team_lead? && accessible_developer?(@developer)
    return if current_user.developer? && @developer.id == current_user.developer_id && can?(:edit_own_profile)

    redirect_to root_path, alert: "You do not have permission to do that."
  end

  def developer_params
    if can?(:manage_all_records)
      params.require(:developer).permit(
        :name, :stack, :education_detail, :passing_year, :b2b_eligible,
        :availability_status, :ready_for_new_project, :on_call_count, :rating, :hourly_cost, :notes, :team_lead_id,
        :incentive_eligible, :incentive_free_project_count, :incentive_amount_per_project
      )
    elsif current_user.team_lead?
      params.require(:developer).permit(
        :name, :stack, :education_detail, :passing_year, :b2b_eligible,
        :availability_status, :ready_for_new_project, :on_call_count, :rating, :hourly_cost, :notes
      )
    else
      params.require(:developer).permit(:availability_status, :ready_for_new_project, :notes)
    end
  end
end
