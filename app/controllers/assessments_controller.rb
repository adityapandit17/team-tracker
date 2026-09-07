class AssessmentsController < ApplicationController
  before_action :set_developer, only: %i[index new create], if: -> { params[:developer_id].present? }
  before_action :set_assessment, only: %i[show edit update destroy]
  before_action :authorize_assessment_manage!, only: %i[new create edit update destroy]
  before_action :authorize_assessment_access!, only: %i[show edit update destroy]

  def index
    @assessments = if @developer
      authorize_record!(@developer)
      return if performed?

      @developer.assessments.includes(:author, :assessment_criteria).order(assessed_on: :desc, created_at: :desc)
    else
      scoped_assessments.includes(:developer, :author, :assessment_criteria).order(assessed_on: :desc, created_at: :desc)
    end
    @assessments = @assessments.where(career_level: params[:career_level]) if params[:career_level].present?
    @assessments = @assessments.where(developer_id: params[:developer_filter]) if params[:developer_filter].present?
    @view = params[:view].presence_in(%w[grid kanban]) || "grid"
  end

  def show
  end

  def new
    @assessment = Assessment.build_with_defaults(
      developer: @developer,
      assessed_on: Date.current,
      career_level: "mid",
      title: @developer ? "#{@developer.name} — Mid assessment" : nil
    )
  end

  def create
    @assessment = Assessment.new(assessment_params)
    @assessment.author = current_user
    @assessment.developer ||= @developer

    authorize_record!(@assessment.developer)
    return if performed?

    if @assessment.save
      redirect_to(@developer ? developer_path(@developer) : @assessment, notice: "Assessment created.")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @assessment.update(assessment_params)
      redirect_to @assessment, notice: "Assessment updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @assessment.destroy
    redirect_to assessments_path, notice: "Assessment removed."
  end

  private

  def set_developer
    @developer = Developer.find(params[:developer_id])
  end

  def set_assessment
    @assessment = Assessment.includes(:assessment_criteria, :developer, :author).find(params[:id])
  end

  def authorize_assessment_manage!
    authorize!(:manage_assessments)
  end

  def authorize_assessment_access!
    authorize_record!(@assessment)
  end

  def assessment_params
    params.require(:assessment).permit(
      :developer_id, :career_level, :title, :summary, :assessed_on,
      assessment_criteria_attributes: %i[id name rating notes position _destroy]
    )
  end
end
