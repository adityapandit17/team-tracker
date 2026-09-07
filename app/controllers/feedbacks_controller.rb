class FeedbacksController < ApplicationController
  before_action :set_developer, only: %i[index new create], if: -> { params[:developer_id].present? }
  before_action :set_feedback, only: %i[show edit update destroy]
  before_action :authorize_feedback_manage!, only: %i[new create edit update destroy]
  before_action :authorize_feedback_access!, only: %i[show edit update destroy]

  def index
    @feedbacks = if @developer
      authorize_record!(@developer)
      return if performed?

      @developer.feedbacks.includes(:author).order(feedback_date: :desc, created_at: :desc)
    else
      scoped_feedbacks.includes(:developer, :author).order(feedback_date: :desc, created_at: :desc)
    end
    @feedbacks = @feedbacks.where(developer_id: params[:developer_filter]) if params[:developer_filter].present?
    @view = params[:view].presence_in(%w[grid kanban]) || "grid"
  end

  def show
  end

  def new
    @feedback = Feedback.new(
      developer: @developer,
      feedback_date: Date.current,
      rating: 3
    )
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.author = current_user
    @feedback.developer ||= @developer

    authorize_record!(@feedback.developer)
    return if performed?

    if @feedback.save
      redirect_to(@developer ? developer_path(@developer) : feedbacks_path, notice: "Feedback added.")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @feedback.update(feedback_params)
      redirect_to @feedback, notice: "Feedback updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    developer = @feedback.developer
    @feedback.destroy
    redirect_to feedbacks_path, notice: "Feedback removed."
  end

  private

  def set_developer
    @developer = Developer.find(params[:developer_id])
  end

  def set_feedback
    @feedback = Feedback.find(params[:id])
  end

  def authorize_feedback_manage!
    authorize!(:manage_feedback)
  end

  def authorize_feedback_access!
    authorize_record!(@feedback)
  end

  def feedback_params
    params.require(:feedback).permit(:developer_id, :title, :body, :rating, :feedback_date)
  end
end
