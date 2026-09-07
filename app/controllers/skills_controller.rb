class SkillsController < ApplicationController
  def index
    @developers = scoped_developers.includes(developer_skills: :skill).order(:name)
    @categories = Skill::CATEGORIES
    @skill_by_category = Skill.order(:id).group_by(&:category).transform_values(&:first)
  end

  def update_cell
    developer = Developer.find(params[:developer_id])
    authorize_record!(developer)
    return if performed?

    unless can?(:manage_all_records) || can?(:edit_own_skills)
      return redirect_to root_path, alert: "You do not have permission to do that."
    end

    skill = Skill.find(params[:skill_id])
    ds = DeveloperSkill.find_or_initialize_by(developer: developer, skill: skill)

    if ds.update(proficiency: params[:proficiency])
      redirect_to skills_path, notice: "Updated #{developer.name}'s #{skill.category} proficiency."
    else
      redirect_to skills_path, alert: ds.errors.full_messages.to_sentence.presence || "Could not update proficiency."
    end
  end
end
