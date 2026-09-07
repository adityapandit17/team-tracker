class AuditsController < ApplicationController
  before_action -> { authorize!(:view_audits) }

  PER_PAGE = 50

  def index
    scope = Audit.recent
    scope = scope.where(auditable_type: params[:type]) if params[:type].present?
    scope = scope.where(action: params[:action_type]) if params[:action_type].in?(Audit::ACTIONS)
    scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?
    scope = scope.where(auditable_id: params[:record_id]) if params[:record_id].present?
    scope = scope.search(params[:q]) if params[:q].present?
    scope = scope.where(created_at: parsed_date(params[:from])&.beginning_of_day..) if parsed_date(params[:from])
    scope = scope.where(created_at: ..parsed_date(params[:to])&.end_of_day) if parsed_date(params[:to])

    @page = [params[:page].to_i, 1].max
    @total = scope.count
    @audits = scope.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
    @last_page = [(@total / PER_PAGE.to_f).ceil, 1].max

    @types = Audit.distinct.pluck(:auditable_type).compact.sort
    @actors = User.order(:name)
  end

  private

  def parsed_date(value)
    return nil if value.blank?

    Date.parse(value)
  rescue Date::Error
    nil
  end
end
