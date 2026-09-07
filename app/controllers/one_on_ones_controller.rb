class OneOnOnesController < ApplicationController
  before_action :set_developer, only: %i[index new create], if: -> { params[:developer_id].present? }
  before_action :set_one_on_one, only: %i[show edit update destroy]
  before_action :authorize_manage!, only: %i[new create edit update destroy]
  before_action :authorize_access!, only: %i[show edit update destroy]

  def index
    @one_on_ones = if @developer
      authorize_record!(@developer)
      return if performed?

      @developer.one_on_ones.includes(:conductor, :growth_plan, :assessment).ordered
    else
      scoped_one_on_ones.includes(:developer, :conductor, :growth_plan, :assessment).ordered
    end
    @one_on_ones = @one_on_ones.where(status: params[:status]) if params[:status].present?
    @due_reviews = @one_on_ones.review_due
  end

  def show
    @linked_action_items = @one_on_one.action_items.includes(:assignee).ordered
  end

  def new
    @one_on_one = OneOnOne.new(
      developer: @developer,
      meeting_on: Date.current,
      next_review_on: Date.current + 14.days,
      status: "scheduled",
      growth_plan_id: params[:growth_plan_id]
    )
  end

  def create
    @one_on_one = OneOnOne.new(one_on_one_params)
    @one_on_one.conductor = current_user
    @one_on_one.developer ||= @developer

    authorize_record!(@one_on_one.developer)
    return if performed?

    if @one_on_one.save
      create_linked_action_items
      redirect_to(@developer ? developer_path(@developer) : @one_on_one, notice: "1:1 saved.")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @one_on_one.update(one_on_one_params)
      create_linked_action_items
      redirect_to @one_on_one, notice: "1:1 updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @one_on_one.destroy
    redirect_to one_on_ones_path, notice: "1:1 removed."
  end

  private

  def set_developer
    @developer = Developer.find(params[:developer_id])
  end

  def set_one_on_one
    @one_on_one = OneOnOne.find(params[:id])
  end

  def authorize_manage!
    authorize!(:manage_one_on_ones)
  end

  def authorize_access!
    authorize_record!(@one_on_one)
  end

  def create_linked_action_items
    lines = params[:action_item_lines].to_s.split("\n")
    @one_on_one.create_action_items_from_lines!(lines, created_by: current_user)
  end

  def one_on_one_params
    params.require(:one_on_one).permit(
      :developer_id, :growth_plan_id, :assessment_id,
      :meeting_on, :notes, :goals, :next_review_on, :status
    )
  end
end
