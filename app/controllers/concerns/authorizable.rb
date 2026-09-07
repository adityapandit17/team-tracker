module Authorizable
  extend ActiveSupport::Concern

  PERMISSIONS = {
    manage_users: %i[admin manager],
    manage_all_records: %i[admin manager],
    view_all_records: %i[admin manager],
    manage_team_developers: %i[admin manager team_lead],
    promote_team_leads: %i[admin manager],
    view_billings: %i[admin manager team_lead],
    manage_billings: %i[admin manager],
    edit_own_profile: %i[admin manager team_lead developer],
    edit_own_skills: %i[admin manager team_lead developer],
    edit_own_projects: %i[admin manager team_lead],
    edit_own_leads: %i[admin manager team_lead],
    manage_feedback: %i[admin manager team_lead],
    manage_assessments: %i[admin manager team_lead],
    manage_developer_action_items: %i[admin manager team_lead],
    manage_one_on_ones: %i[admin manager team_lead],
    manage_growth_plans: %i[admin manager team_lead],
    manage_allocations: %i[admin manager team_lead],
    view_utilization: %i[admin manager team_lead],
    view_incentives: %i[admin manager team_lead],
    manage_incentives: %i[admin manager],
    view_audits: %i[admin manager],
    view_hierarchy: %i[admin manager team_lead developer]
  }.freeze

  def can?(permission)
    roles = PERMISSIONS.fetch(permission) { return false }
    roles.include?(current_user.role.to_sym)
  end

  def cannot?(permission)
    !can?(permission)
  end

  def authorize!(permission)
    return if can?(permission)

    redirect_to root_path, alert: "You do not have permission to do that."
  end

  def authorize_record!(record)
    return if current_user.staff?
    return if owns_record?(record)

    redirect_to root_path, alert: "You can only access your own data."
  end

  def owns_record?(record)
    case record
    when Developer
      accessible_developer?(record)
    when Project
      project_in_scope?(record)
    when ClientLead
      client_lead_in_scope?(record)
    when Feedback, Assessment, GrowthPlan, OneOnOne, Allocation
      accessible_developer?(record.developer)
    when ActionItem
      action_item_in_scope?(record)
    else
      false
    end
  end

  def accessible_developer?(developer)
    current_user.accessible_developer_ids.include?(developer.id)
  end

  def project_in_scope?(project)
    ids = current_user.accessible_developer_ids
    [project.call_developer_id, project.main_developer_id, project.helper_developer_id, project.lead_developer_id]
      .compact.intersect?(ids)
  end

  def client_lead_in_scope?(lead)
    current_user.accessible_developer_ids.include?(lead.assignee_id)
  end

  def action_item_in_scope?(item)
    return true if item.assignee_id == current_user.id
    return accessible_developer?(item.developer) if item.developer_id.present?

    false
  end

  def scoped_developers
    return Developer.all if current_user.staff?

    Developer.where(id: current_user.accessible_developer_ids)
  end

  def scoped_projects
    return Project.all if current_user.staff?

    ids = current_user.accessible_developer_ids
    return Project.none if ids.empty?

    Project.where(
      "call_developer_id IN (:ids) OR main_developer_id IN (:ids) OR helper_developer_id IN (:ids) OR lead_developer_id IN (:ids)",
      ids: ids
    )
  end

  def scoped_client_leads
    return ClientLead.all if current_user.staff?

    ClientLead.where(assignee_id: current_user.accessible_developer_ids)
  end

  def scoped_feedbacks
    return Feedback.all if current_user.staff?

    Feedback.where(developer_id: current_user.accessible_developer_ids)
  end

  def scoped_assessments
    return Assessment.all if current_user.staff?

    Assessment.where(developer_id: current_user.accessible_developer_ids)
  end

  def scoped_action_items
    if current_user.staff?
      ActionItem.all
    elsif current_user.team_lead?
      ActionItem.where(
        "assignee_id = :uid OR developer_id IN (:dev_ids)",
        uid: current_user.id,
        dev_ids: current_user.accessible_developer_ids
      )
    else
      ActionItem.where(assignee_id: current_user.id)
    end
  end

  def scoped_growth_plans
    return GrowthPlan.all if current_user.staff?

    GrowthPlan.where(developer_id: current_user.accessible_developer_ids)
  end

  def scoped_one_on_ones
    return OneOnOne.all if current_user.staff?

    OneOnOne.where(developer_id: current_user.accessible_developer_ids)
  end

  def scoped_allocations
    return Allocation.all if current_user.staff?

    Allocation.where(developer_id: current_user.accessible_developer_ids)
  end

  def team_lead_options
    User.team_lead.order(:name)
  end
end
