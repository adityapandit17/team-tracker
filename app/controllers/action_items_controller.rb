class ActionItemsController < ApplicationController
  before_action :set_developer, only: %i[index new create], if: -> { params[:developer_id].present? }
  before_action :set_action_item, only: %i[show edit update destroy update_status]
  before_action :authorize_action_item_write!, only: %i[new create edit update destroy update_status]
  before_action :authorize_action_item_access!, only: %i[show edit update destroy update_status]

  def index
    if @developer
      authorize_record!(@developer)
      return if performed?

      @action_items = @developer.action_items.includes(:assignee, :created_by).ordered
    else
      @action_items = scoped_action_items.includes(:developer, :assignee, :created_by).ordered
      @action_items = @action_items.where(assignee_id: current_user.id) if params[:mine] == "1"
      @action_items = @action_items.personal if params[:personal] == "1"
      @action_items = @action_items.where(status: params[:status]) if params[:status].present?
      @action_items = @action_items.where(developer_id: params[:developer_filter]) if params[:developer_filter].present?
    end

    @view = params[:view].presence_in(%w[grid kanban]) || "kanban"
    @grouped = ActionItem.statuses.keys.index_with { |s| @action_items.select { |i| i.status == s } }
  end

  def show
  end

  def new
    @action_item = ActionItem.new(
      developer: @developer,
      assignee: default_assignee,
      status: "todo",
      priority: "medium",
      due_on: Date.current + 7.days
    )
  end

  def create
    @action_item = ActionItem.new(action_item_params)
    @action_item.created_by = current_user
    @action_item.developer ||= @developer
    @action_item.assignee ||= current_user

    unless can_write_action_item?(@action_item)
      return redirect_to root_path, alert: "You do not have permission to do that."
    end

    if @action_item.save
      redirect_to(@developer ? developer_path(@developer) : action_items_path(view: params[:view]), notice: "Action item added.")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    unless can_write_action_item?(@action_item)
      return redirect_to root_path, alert: "You do not have permission to do that."
    end

    if @action_item.update(action_item_params)
      redirect_to action_items_path(view: params[:view]), notice: "Action item updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_status
    unless can_write_action_item?(@action_item)
      return head :forbidden
    end

    status = params[:status].presence_in(ActionItem.statuses.keys)
    position = params[:position].presence&.to_i

    attrs = {}
    attrs[:status] = status if status
    attrs[:position] = position if !position.nil?

    if attrs.present? && @action_item.update(attrs)
      respond_to do |format|
        format.html { redirect_to action_items_path(view: "kanban"), notice: "Status updated." }
        format.json { render json: { ok: true, status: @action_item.status, position: @action_item.position } }
      end
    else
      respond_to do |format|
        format.html { redirect_to action_items_path(view: "kanban"), alert: "Could not update status." }
        format.json { render json: { ok: false, errors: @action_item.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    unless can_write_action_item?(@action_item)
      return redirect_to root_path, alert: "You do not have permission to do that."
    end

    @action_item.destroy
    redirect_to action_items_path, notice: "Action item removed."
  end

  private

  def set_developer
    @developer = Developer.find(params[:developer_id])
  end

  def set_action_item
    @action_item = ActionItem.find(params[:id])
  end

  def authorize_action_item_access!
    authorize_record!(@action_item)
  end

  def authorize_action_item_write!
    # Personal todos: any user can create for themselves; developer-linked needs manage permission
    return if action_name.in?(%w[new create]) && personal_todo_create?
    return if can?(:manage_developer_action_items)
    return if @action_item&.assignee_id == current_user.id

    redirect_to root_path, alert: "You do not have permission to do that."
  end

  def personal_todo_create?
    return true if params[:developer_id].blank? && params.dig(:action_item, :developer_id).blank?

    false
  end

  def can_write_action_item?(item)
    return true if can?(:manage_developer_action_items) && (item.developer_id.blank? || accessible_developer?(item.developer) || current_user.staff?)
    return true if item.assignee_id == current_user.id && (item.personal? || item.developer_id.blank? || accessible_developer?(item.developer))

    false
  end

  def default_assignee
    if @developer&.user
      @developer.user
    else
      current_user
    end
  end

  def action_item_params
    permitted = %i[title description status priority due_on position]
    if can?(:manage_developer_action_items)
      permitted += %i[developer_id assignee_id]
    elsif current_user.developer?
      # developers may only manage personal todos / items assigned to them
      permitted
    else
      permitted += %i[developer_id assignee_id]
    end

    attrs = params.require(:action_item).permit(*permitted)
    attrs[:developer_id] = nil if attrs[:developer_id].blank?
    attrs
  end
end
