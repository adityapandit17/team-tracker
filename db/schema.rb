# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_09_07_190000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_items", force: :cascade do |t|
    t.bigint "developer_id"
    t.bigint "assignee_id", null: false
    t.bigint "created_by_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "status", default: "todo", null: false
    t.string "priority", default: "medium", null: false
    t.date "due_on"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "one_on_one_id"
    t.bigint "growth_plan_id"
    t.index ["assignee_id"], name: "index_action_items_on_assignee_id"
    t.index ["created_by_id"], name: "index_action_items_on_created_by_id"
    t.index ["developer_id"], name: "index_action_items_on_developer_id"
    t.index ["growth_plan_id"], name: "index_action_items_on_growth_plan_id"
    t.index ["one_on_one_id"], name: "index_action_items_on_one_on_one_id"
    t.index ["priority"], name: "index_action_items_on_priority"
    t.index ["status"], name: "index_action_items_on_status"
  end

  create_table "allocations", force: :cascade do |t|
    t.bigint "developer_id", null: false
    t.bigint "project_id", null: false
    t.string "role", default: "main", null: false
    t.integer "allocation_pct", default: 100, null: false
    t.date "start_on", null: false
    t.date "end_on"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["developer_id", "project_id"], name: "index_allocations_on_developer_id_and_project_id"
    t.index ["developer_id"], name: "index_allocations_on_developer_id"
    t.index ["end_on"], name: "index_allocations_on_end_on"
    t.index ["project_id"], name: "index_allocations_on_project_id"
    t.index ["start_on"], name: "index_allocations_on_start_on"
  end

  create_table "assessment_criteria", force: :cascade do |t|
    t.bigint "assessment_id", null: false
    t.string "name", null: false
    t.integer "rating", null: false
    t.text "notes"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id"], name: "index_assessment_criteria_on_assessment_id"
  end

  create_table "assessments", force: :cascade do |t|
    t.bigint "developer_id", null: false
    t.bigint "author_id", null: false
    t.string "career_level", null: false
    t.string "title", null: false
    t.text "summary"
    t.decimal "overall_rating", precision: 3, scale: 2
    t.date "assessed_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_assessments_on_author_id"
    t.index ["career_level"], name: "index_assessments_on_career_level"
    t.index ["developer_id"], name: "index_assessments_on_developer_id"
  end

  create_table "audits", force: :cascade do |t|
    t.string "auditable_type", null: false
    t.bigint "auditable_id", null: false
    t.string "action", null: false
    t.bigint "user_id"
    t.string "user_label"
    t.string "record_label"
    t.jsonb "audited_changes", default: {}, null: false
    t.string "ip_address"
    t.string "request_uuid"
    t.datetime "created_at", null: false
    t.index ["action"], name: "index_audits_on_action"
    t.index ["auditable_type", "auditable_id", "created_at"], name: "index_audits_on_auditable_and_time"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["user_id"], name: "index_audits_on_user_id"
  end

  create_table "client_leads", force: :cascade do |t|
    t.string "client_name", null: false
    t.bigint "assignee_id"
    t.string "calls"
    t.string "tests"
    t.string "status", default: "hold", null: false
    t.integer "rounds", default: 0
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_client_leads_on_assignee_id"
  end

  create_table "developer_skills", force: :cascade do |t|
    t.bigint "developer_id", null: false
    t.bigint "skill_id", null: false
    t.string "proficiency", default: "na", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["developer_id", "skill_id"], name: "index_developer_skills_on_developer_id_and_skill_id", unique: true
    t.index ["developer_id"], name: "index_developer_skills_on_developer_id"
    t.index ["skill_id"], name: "index_developer_skills_on_skill_id"
  end

  create_table "developers", force: :cascade do |t|
    t.string "name", null: false
    t.string "stack", default: "other", null: false
    t.string "education_detail"
    t.integer "passing_year"
    t.boolean "b2b_eligible"
    t.string "availability_status", default: "available", null: false
    t.boolean "ready_for_new_project", default: true
    t.integer "on_call_count", default: 0
    t.decimal "rating", precision: 3, scale: 1
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_lead_id"
    t.decimal "hourly_cost", precision: 10, scale: 2
    t.boolean "incentive_eligible", default: false, null: false
    t.integer "incentive_free_project_count", default: 0, null: false
    t.decimal "incentive_amount_per_project", precision: 12, scale: 2
    t.index ["team_lead_id"], name: "index_developers_on_team_lead_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.bigint "developer_id", null: false
    t.bigint "author_id", null: false
    t.string "title", null: false
    t.text "body"
    t.integer "rating", null: false
    t.date "feedback_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_feedbacks_on_author_id"
    t.index ["developer_id"], name: "index_feedbacks_on_developer_id"
  end

  create_table "growth_plans", force: :cascade do |t|
    t.bigint "developer_id", null: false
    t.bigint "owner_id", null: false
    t.bigint "assessment_id"
    t.string "title", null: false
    t.string "target_career_level"
    t.text "goals"
    t.text "focus_areas"
    t.date "next_review_on"
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id"], name: "index_growth_plans_on_assessment_id"
    t.index ["developer_id"], name: "index_growth_plans_on_developer_id"
    t.index ["next_review_on"], name: "index_growth_plans_on_next_review_on"
    t.index ["owner_id"], name: "index_growth_plans_on_owner_id"
    t.index ["status"], name: "index_growth_plans_on_status"
  end

  create_table "one_on_ones", force: :cascade do |t|
    t.bigint "developer_id", null: false
    t.bigint "conductor_id", null: false
    t.bigint "growth_plan_id"
    t.bigint "assessment_id"
    t.date "meeting_on", null: false
    t.text "notes"
    t.text "goals"
    t.date "next_review_on"
    t.string "status", default: "scheduled", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id"], name: "index_one_on_ones_on_assessment_id"
    t.index ["conductor_id"], name: "index_one_on_ones_on_conductor_id"
    t.index ["developer_id"], name: "index_one_on_ones_on_developer_id"
    t.index ["growth_plan_id"], name: "index_one_on_ones_on_growth_plan_id"
    t.index ["meeting_on"], name: "index_one_on_ones_on_meeting_on"
    t.index ["next_review_on"], name: "index_one_on_ones_on_next_review_on"
    t.index ["status"], name: "index_one_on_ones_on_status"
  end

  create_table "project_billings", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.date "billing_month", null: false
    t.decimal "hours_billed", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "amount", precision: 12, scale: 2
    t.string "status", default: "pending", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "billing_month"], name: "index_project_billings_on_project_id_and_billing_month", unique: true
    t.index ["project_id"], name: "index_project_billings_on_project_id"
    t.index ["status"], name: "index_project_billings_on_status"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.string "status", default: "active", null: false
    t.string "technology"
    t.bigint "call_developer_id"
    t.bigint "main_developer_id"
    t.bigint "helper_developer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "start_date"
    t.string "billing_type", default: "monthly", null: false
    t.decimal "fixed_amount", precision: 12, scale: 2
    t.decimal "hourly_rate", precision: 10, scale: 2
    t.bigint "lead_developer_id"
    t.boolean "incentive_eligible", default: true, null: false
    t.index ["call_developer_id"], name: "index_projects_on_call_developer_id"
    t.index ["helper_developer_id"], name: "index_projects_on_helper_developer_id"
    t.index ["lead_developer_id"], name: "index_projects_on_lead_developer_id"
    t.index ["main_developer_id"], name: "index_projects_on_main_developer_id"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name", null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_skills_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.integer "role", default: 3, null: false
    t.bigint "developer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["developer_id"], name: "index_users_on_developer_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "action_items", "developers"
  add_foreign_key "action_items", "growth_plans"
  add_foreign_key "action_items", "one_on_ones"
  add_foreign_key "action_items", "users", column: "assignee_id"
  add_foreign_key "action_items", "users", column: "created_by_id"
  add_foreign_key "allocations", "developers"
  add_foreign_key "allocations", "projects"
  add_foreign_key "assessment_criteria", "assessments"
  add_foreign_key "assessments", "developers"
  add_foreign_key "assessments", "users", column: "author_id"
  add_foreign_key "audits", "users", on_delete: :nullify
  add_foreign_key "client_leads", "developers", column: "assignee_id"
  add_foreign_key "developer_skills", "developers"
  add_foreign_key "developer_skills", "skills"
  add_foreign_key "developers", "users", column: "team_lead_id"
  add_foreign_key "feedbacks", "developers"
  add_foreign_key "feedbacks", "users", column: "author_id"
  add_foreign_key "growth_plans", "assessments"
  add_foreign_key "growth_plans", "developers"
  add_foreign_key "growth_plans", "users", column: "owner_id"
  add_foreign_key "one_on_ones", "assessments"
  add_foreign_key "one_on_ones", "developers"
  add_foreign_key "one_on_ones", "growth_plans"
  add_foreign_key "one_on_ones", "users", column: "conductor_id"
  add_foreign_key "project_billings", "projects"
  add_foreign_key "projects", "developers", column: "call_developer_id"
  add_foreign_key "projects", "developers", column: "helper_developer_id"
  add_foreign_key "projects", "developers", column: "lead_developer_id"
  add_foreign_key "projects", "developers", column: "main_developer_id"
  add_foreign_key "users", "developers"
end
