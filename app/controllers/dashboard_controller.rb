class DashboardController < ApplicationController
  def index
    developers = scoped_developers
    projects = scoped_projects
    leads = scoped_client_leads

    @developer_count = developers.count
    @active_projects = projects.active.count
    @ready_count = developers.where(ready_for_new_project: true).count
    @avg_rating = developers.where.not(rating: nil).average(:rating)&.round(2)
    @open_leads = leads.where(status: [:hold, :active]).count

    @stack_breakdown = developers.group(:stack).count
    @project_status_breakdown = projects.group(:status).count
    @top_rated = developers.where.not(rating: nil).order(rating: :desc).limit(5)
    @on_call_now = developers.where("on_call_count > 0").order(on_call_count: :desc)
    @scoped_view = current_user.scoped?
  end
end
