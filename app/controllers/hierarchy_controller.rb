class HierarchyController < ApplicationController
  before_action -> { authorize!(:view_hierarchy) }

  def index
    @chart = OrgChart.new
    @totals = @chart.totals
  end
end
