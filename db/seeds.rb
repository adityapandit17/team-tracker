puts "Seeding..."

User.destroy_all
ActionItem.destroy_all
OneOnOne.destroy_all
GrowthPlan.destroy_all
Allocation.destroy_all
Assessment.destroy_all
Feedback.destroy_all
ClientLead.destroy_all
Project.destroy_all
DeveloperSkill.destroy_all
Skill.destroy_all
Developer.destroy_all

# ---------- Developers ----------
# stack: which team sheet they primarily sit under (ROR / MERN)
developers_data = [
  { name: "Yashika Vijayvargiya", stack: "ror", education_detail: "B. Tech", passing_year: 2021, b2b_eligible: true, availability_status: "available", ready_for_new_project: false, on_call_count: 3, rating: 5.0 },
  { name: "Himanshu Rai", stack: "ror", education_detail: "BE (Electrical & Electronics)", passing_year: 2019, b2b_eligible: true, availability_status: "available", ready_for_new_project: true, on_call_count: 1, rating: 4.0 },
  { name: "Sakshi Khalorkar", stack: "ror", education_detail: "Btech", passing_year: 2022, b2b_eligible: false, availability_status: "available", ready_for_new_project: true, on_call_count: 1, rating: 2.5 },
  { name: "Sakshi Chouhan", stack: "ror", education_detail: "B. Tech", passing_year: 2024, b2b_eligible: false, availability_status: "available", ready_for_new_project: true, on_call_count: 1, rating: 3.0 },
  { name: "Parth Patki", stack: "ror", education_detail: "Btech", passing_year: 2023, b2b_eligible: false, availability_status: "available", ready_for_new_project: false, on_call_count: 2, rating: 4.0 },
  { name: "Priyanshu Nigam", stack: "ror", education_detail: nil, passing_year: nil, b2b_eligible: nil, availability_status: "available", ready_for_new_project: true, on_call_count: 0, rating: nil },
  { name: "Mayank Khajure", stack: "ror", education_detail: "BCA", passing_year: 2020, b2b_eligible: true, availability_status: "not_available", ready_for_new_project: true, on_call_count: 0, rating: 2.0 },
  { name: "Vicki Mahajan", stack: "ror", education_detail: "B Tech", passing_year: 2026, b2b_eligible: false, availability_status: "not_available", ready_for_new_project: true, on_call_count: 0, rating: 2.0 },
  { name: "Devendra Verma", stack: "ror", education_detail: "B.Tech CS", passing_year: 2021, b2b_eligible: true, availability_status: "available", ready_for_new_project: true, on_call_count: 0, rating: 2.0 },
  { name: "Anand Paradkar", stack: "ror", education_detail: nil, passing_year: nil, b2b_eligible: false, availability_status: "available", ready_for_new_project: true, on_call_count: 0, rating: 2.0 },
  { name: "Palak Patel", stack: "ror", education_detail: "B.Sc CS", passing_year: 2021, b2b_eligible: true, availability_status: "available", ready_for_new_project: true, on_call_count: 0, rating: 3.0 },
  { name: "Jay Thakur", stack: "ror", education_detail: "Btech", passing_year: 2021, b2b_eligible: true, availability_status: "available", ready_for_new_project: true, on_call_count: 0, rating: 3.0 },
  { name: "RamKrishan Patidar", stack: "ror", education_detail: "BCA-2021", passing_year: 2021, b2b_eligible: true, availability_status: "available", ready_for_new_project: true, on_call_count: 0, rating: 2.5 },
  { name: "Shahir Mansoori", stack: "ror", education_detail: nil, passing_year: nil, b2b_eligible: nil, availability_status: "not_available", ready_for_new_project: true, on_call_count: 0, rating: 2.5 },
  { name: "Aditya Pandit", stack: "ror", education_detail: "BE CS", passing_year: 2019, b2b_eligible: true, availability_status: "not_available", ready_for_new_project: true, on_call_count: 0, rating: 5.0 },
  { name: "Sanskar Gupta", stack: "mern", education_detail: nil, passing_year: nil, b2b_eligible: nil, availability_status: "available", ready_for_new_project: false, on_call_count: 0, rating: nil },
  { name: "Mamta Rajawat", stack: "mern", education_detail: nil, passing_year: nil, b2b_eligible: false, availability_status: "available", ready_for_new_project: true, on_call_count: 0, rating: nil },
  { name: "Himanshi Joshi", stack: "mern", education_detail: nil, passing_year: nil, b2b_eligible: false, availability_status: "available", ready_for_new_project: true, on_call_count: 0, rating: nil },
]

by_name = {}
developers_data.each do |data|
  d = Developer.create!(data)
  by_name[d.name] = d
end

# ---------- Skills ----------
skills_data = [
  ["React", "Frontend"], ["Vue", "Frontend"], ["HTML/CSS", "Frontend"],
  ["Ruby on Rails", "Backend"], ["Node.js", "Backend"], ["Express", "Backend"],
  ["PostgreSQL", "Database"], ["MongoDB", "Database"],
  ["AWS", "Cloud / DevOps"], ["Docker", "Cloud / DevOps"],
  ["React Native", "Mobile"],
  ["RSpec", "QA / Testing"], ["Jest", "QA / Testing"],
  ["LLM Integration", "AI / ML"],
  ["System Design", "System Design"],
]
skills = skills_data.map { |name, category| Skill.create!(name: name, category: category) }

skill_matrix = {
  "Yashika Vijayvargiya" => { "Frontend" => "advanced", "Backend" => "advanced", "Database" => "intermediate", "Cloud / DevOps" => "advanced", "Mobile" => "na", "QA / Testing" => "intermediate", "AI / ML" => "na", "System Design" => "expert" },
  "Devendra Verma" => { "Frontend" => "advanced", "Backend" => "expert", "Database" => "advanced", "Cloud / DevOps" => "advanced", "Mobile" => "na", "QA / Testing" => "intermediate", "AI / ML" => "na", "System Design" => "advanced" },
  "Anand Paradkar" => { "Frontend" => "intermediate", "Backend" => "advanced", "Database" => "advanced", "Cloud / DevOps" => "expert", "Mobile" => "na", "QA / Testing" => "advanced", "AI / ML" => "intermediate", "System Design" => "advanced" },
  "Palak Patel" => { "Frontend" => "expert", "Backend" => "advanced", "Database" => "intermediate", "Cloud / DevOps" => "intermediate", "Mobile" => "na", "QA / Testing" => "intermediate", "AI / ML" => "na", "System Design" => "intermediate" },
  "Sakshi Khalorkar" => { "Frontend" => "advanced", "Backend" => "advanced", "Database" => "advanced", "Cloud / DevOps" => "intermediate", "Mobile" => "na", "QA / Testing" => "advanced", "AI / ML" => "intermediate", "System Design" => "intermediate" },
  "Sakshi Chouhan" => { "Frontend" => "intermediate", "Backend" => "intermediate", "Database" => "beginner", "Cloud / DevOps" => "beginner", "Mobile" => "na", "QA / Testing" => "intermediate", "AI / ML" => "na", "System Design" => "beginner" },
  "Parth Patki" => { "Frontend" => "advanced", "Backend" => "intermediate", "Database" => "intermediate", "Cloud / DevOps" => "beginner", "Mobile" => "na", "QA / Testing" => "advanced", "AI / ML" => "na", "System Design" => "beginner" },
  "Jay Thakur" => { "Frontend" => "beginner", "Backend" => "beginner", "Database" => "beginner", "Cloud / DevOps" => "na", "Mobile" => "na", "QA / Testing" => "beginner", "AI / ML" => "na", "System Design" => "na" },
  "Mayank Khajure" => { "Frontend" => "intermediate", "Backend" => "expert", "Database" => "advanced", "Cloud / DevOps" => "advanced", "Mobile" => "na", "QA / Testing" => "intermediate", "AI / ML" => "advanced", "System Design" => "advanced" },
  "Vicki Mahajan" => { "Frontend" => "intermediate", "Backend" => "intermediate", "Database" => "intermediate", "Cloud / DevOps" => "beginner", "Mobile" => "na", "QA / Testing" => "intermediate", "AI / ML" => "na", "System Design" => "beginner" },
  "Himanshu Rai" => { "Frontend" => "advanced", "Backend" => "intermediate", "Database" => "intermediate", "Cloud / DevOps" => "intermediate", "Mobile" => "advanced", "QA / Testing" => "beginner", "AI / ML" => "na", "System Design" => "intermediate" },
  "RamKrishan Patidar" => { "Frontend" => "beginner", "Backend" => "beginner", "Database" => "na", "Cloud / DevOps" => "na", "Mobile" => "beginner", "QA / Testing" => "beginner", "AI / ML" => "na", "System Design" => "na" },
  "Shahir Mansoori" => { "Frontend" => "intermediate", "Backend" => "advanced", "Database" => "intermediate", "Cloud / DevOps" => "beginner", "Mobile" => "na", "QA / Testing" => "expert", "AI / ML" => "na", "System Design" => "intermediate" },
  "Aditya Pandit" => { "Frontend" => "intermediate", "Backend" => "advanced", "Database" => "intermediate", "Cloud / DevOps" => "beginner", "Mobile" => "na", "QA / Testing" => "advanced", "AI / ML" => "na", "System Design" => "intermediate" },
}

# map category -> a representative skill name we seeded, so we can attach a proficiency per category
category_to_skill = {
  "Frontend" => "React", "Backend" => "Ruby on Rails", "Database" => "PostgreSQL",
  "Cloud / DevOps" => "AWS", "Mobile" => "React Native", "QA / Testing" => "RSpec",
  "AI / ML" => "LLM Integration", "System Design" => "System Design",
}
skill_by_name = skills.index_by(&:name)

skill_matrix.each do |dev_name, profs|
  dev = by_name[dev_name]
  next unless dev
  profs.each do |category, level|
    skill = skill_by_name[category_to_skill[category]]
    DeveloperSkill.create!(developer: dev, skill: skill, proficiency: level)
  end
end

# ---------- Projects ----------
projects_data = [
  { name: "Novatro", status: "active", technology: "ROR", billing_type: "monthly", start: "2026-01-01", call: "Yashika Vijayvargiya", main: "Palak Patel", helper: nil },
  { name: "Bacancy", status: "active", technology: "ROR", billing_type: "monthly", start: "2025-11-01", call: "Yashika Vijayvargiya", main: "Devendra Verma", helper: nil },
  { name: "Matrix One", status: "active", technology: "ROR + React", billing_type: "fixed_price", fixed_amount: 450000, start: "2026-03-01", call: "Yashika Vijayvargiya", main: "Anand Paradkar", helper: nil },
  { name: "New Bridge Fintech", status: "active", technology: "MERN", billing_type: "monthly", start: "2026-02-01", call: "Sanskar Gupta", main: "Himanshi Joshi", helper: nil },
  { name: "Aaxis", status: "active", technology: "MERN", billing_type: "monthly", start: "2026-01-15", call: "Sanskar Gupta", main: "Mamta Rajawat", helper: nil },
  { name: "Ecosmob", status: "active", technology: "ROR", billing_type: "monthly", start: "2025-12-01", call: "Himanshu Rai", main: "RamKrishan Patidar", helper: nil },
  { name: "DigiRamp", status: "active", technology: "ROR", billing_type: "fixed_price", fixed_amount: 280000, start: "2026-04-01", call: nil, main: nil, helper: nil },
  { name: "Sasken / IMA", status: "active", technology: "ROR", billing_type: "monthly", start: "2026-05-01", call: "Sakshi Chouhan", main: "Sakshi Chouhan", helper: nil },
  { name: "Svitla / Coupa", status: "active", technology: "ROR", billing_type: "monthly", start: "2026-02-01", call: "Parth Patki", main: "Parth Patki", helper: nil },
  { name: "MRO", status: "active", technology: "ROR", billing_type: "monthly", start: "2026-03-01", call: "Parth Patki", main: "Jay Thakur", helper: nil },
  { name: "exactrx.ai", status: "active", technology: "ROR", billing_type: "fixed_price", fixed_amount: 320000, start: "2026-06-01", call: "Priyanshu Nigam", main: "Priyanshu Nigam", helper: nil },
]

projects_by_name = {}
projects_data.each do |p|
  project = Project.create!(
    name: p[:name], status: p[:status], technology: p[:technology],
    billing_type: p[:billing_type], fixed_amount: p[:fixed_amount],
    start_date: Date.parse(p[:start]),
    call_developer: by_name[p[:call]], main_developer: by_name[p[:main]], helper_developer: by_name[p[:helper]]
  )
  project.ensure_billing_periods!
  projects_by_name[project.name] = project
end

# Sample hours / clearance on a few monthly projects
[
  ["Novatro", "2026-01-01", 152, 228000, "cleared"],
  ["Novatro", "2026-02-01", 160, 240000, "cleared"],
  ["Novatro", "2026-03-01", 148, 222000, "cleared"],
  ["Novatro", "2026-04-01", 156, 234000, "pending"],
  ["Novatro", "2026-05-01", 140, 210000, "pending"],
  ["Bacancy", "2025-11-01", 120, 180000, "cleared"],
  ["Bacancy", "2025-12-01", 132, 198000, "cleared"],
  ["Bacancy", "2026-01-01", 128, 192000, "cleared"],
  ["Bacancy", "2026-02-01", 130, 195000, "pending"],
  ["Ecosmob", "2025-12-01", 100, 150000, "cleared"],
  ["Ecosmob", "2026-01-01", 110, 165000, "cleared"],
  ["Ecosmob", "2026-02-01", 108, 162000, "pending"],
  ["Svitla / Coupa", "2026-02-01", 90, 135000, "cleared"],
  ["Svitla / Coupa", "2026-03-01", 96, 144000, "pending"],
  ["Matrix One", "2026-03-01", 0, 450000, "pending"],
  ["DigiRamp", "2026-04-01", 0, 280000, "pending"],
].each do |name, month, hours, amount, status|
  billing = projects_by_name[name].project_billings.find_or_initialize_by(billing_month: Date.parse(month))
  billing.update!(hours_billed: hours, amount: amount, status: status)
end

# ---------- Client Leads (sales pipeline) ----------
[
  { client_name: "Bacancy — Himanshu", assignee: "Himanshu Rai", calls: "Himanshu", tests: "-", status: "hold", rounds: 1, remarks: nil },
  { client_name: "Bacancy — Aditya", assignee: "Aditya Pandit", calls: nil, tests: nil, status: "hold", rounds: 1, remarks: nil },
  { client_name: "Eli — Yashika", assignee: "Yashika Vijayvargiya", calls: nil, tests: nil, status: "active", rounds: 1, remarks: nil },
  { client_name: "David — Akhilesh", assignee: "Aditya Pandit", calls: "Aditya", tests: "Yashika", status: "active", rounds: 1, remarks: nil },
  { client_name: "NovaSoft — Himanshu", assignee: "Himanshu Rai", calls: "Himanshu", tests: "Yashika", status: "won", rounds: 2, remarks: "Closed after 2 rounds" },
  { client_name: "PixelOps — Himanshu", assignee: "Himanshu Rai", calls: "Himanshu", tests: "-", status: "lost", rounds: 3, remarks: "Client went with another vendor" },
  { client_name: "CloudSpan — Himanshu", assignee: "Himanshu Rai", calls: "Himanshu", tests: "Parth", status: "won", rounds: 1, remarks: nil },
  { client_name: "BrightPath — Himanshu", assignee: "Himanshu Rai", calls: nil, tests: nil, status: "active", rounds: 2, remarks: "Waiting on next call" },
  { client_name: "OrbitPay — Aditya", assignee: "Aditya Pandit", calls: "Aditya", tests: "Yashika", status: "won", rounds: 2, remarks: nil },
  { client_name: "Lumen — Aditya", assignee: "Aditya Pandit", calls: "Aditya", tests: "-", status: "lost", rounds: 1, remarks: nil },
  { client_name: "ForgeAI — Yashika", assignee: "Yashika Vijayvargiya", calls: "Yashika", tests: "Palak", status: "won", rounds: 2, remarks: nil },
  { client_name: "Northwind — Yashika", assignee: "Yashika Vijayvargiya", calls: "Yashika", tests: "-", status: "hold", rounds: 1, remarks: nil },
  { client_name: "Svitla follow-up — Parth", assignee: "Parth Patki", calls: "Parth", tests: "Parth", status: "won", rounds: 1, remarks: nil },
  { client_name: "MRO addon — Parth", assignee: "Parth Patki", calls: "Parth", tests: "-", status: "active", rounds: 2, remarks: nil },
  { client_name: "Gridline — Palak", assignee: "Palak Patel", calls: "Palak", tests: "Yashika", status: "won", rounds: 3, remarks: nil },
  { client_name: "Amberdesk — Palak", assignee: "Palak Patel", calls: "Palak", tests: "-", status: "lost", rounds: 2, remarks: nil },
].each do |cl|
  ClientLead.create!(
    client_name: cl[:client_name], assignee: by_name[cl[:assignee]], calls: cl[:calls],
    tests: cl[:tests], status: cl[:status], rounds: cl[:rounds], remarks: cl[:remarks]
  )
end

# ---------- Users (Devise) ----------
users = [
  { name: "Admin User", email: "admin@teamtracker.test", role: :admin, password: "password123", developer: nil },
  { name: "Ops Manager", email: "manager@teamtracker.test", role: :manager, password: "password123", developer: nil },
  { name: "Yashika Vijayvargiya", email: "lead@teamtracker.test", role: :team_lead, password: "password123", developer: by_name["Yashika Vijayvargiya"] },
  { name: "Himanshu Rai", email: "developer@teamtracker.test", role: :developer, password: "password123", developer: by_name["Himanshu Rai"] },
]

users.each do |attrs|
  User.create!(
    name: attrs[:name],
    email: attrs[:email],
    role: attrs[:role],
    password: attrs[:password],
    password_confirmation: attrs[:password],
    developer: attrs[:developer]
  )
end

# Assign ROR developers to Yashika (team lead)
yashika_lead = User.find_by!(email: "lead@teamtracker.test")
[
  "Himanshu Rai", "Sakshi Khalorkar", "Sakshi Chouhan", "Parth Patki", "Priyanshu Nigam",
  "Devendra Verma", "Anand Paradkar", "Palak Patel", "Jay Thakur", "RamKrishan Patidar",
  "Aditya Pandit"
].each do |name|
  by_name[name]&.update!(team_lead: yashika_lead)
end

# ---------- Feedback / Assessments / Action items ----------
admin = User.find_by!(email: "admin@teamtracker.test")
lead = yashika_lead
himanshu = by_name["Himanshu Rai"]
palak = by_name["Palak Patel"]
dev_user = User.find_by!(email: "developer@teamtracker.test")

[
  { developer: himanshu, author: lead, title: "Solid client call presence", body: "Handled Bacancy follow-ups confidently. Keep tightening discovery questions.", rating: 4, feedback_date: Date.current - 12 },
  { developer: himanshu, author: admin, title: "Mobile delivery on Ecosmob", body: "React Native work landed cleanly. Document edge cases next sprint.", rating: 5, feedback_date: Date.current - 4 },
  { developer: palak, author: lead, title: "Novatro frontend ownership", body: "Strong UI polish. Pair more on backend handoffs.", rating: 4, feedback_date: Date.current - 7 },
].each { |attrs| Feedback.create!(attrs) }

assessment = Assessment.new(
  developer: himanshu,
  author: lead,
  career_level: "mid",
  title: "Himanshu — Mid-level review",
  summary: "Ready for broader ownership on client-facing work.",
  assessed_on: Date.current - 3
)
[
  ["Communication", 4, "Clear in standups"],
  ["Code quality", 4, "Consistent PRs"],
  ["Ownership", 3, "Grow proactive scoping"],
  ["Delivery", 5, "Hits dates"],
  ["Collaboration", 4, "Works well with Yashika"]
].each_with_index do |(name, rating, notes), i|
  assessment.assessment_criteria.build(name: name, rating: rating, notes: notes, position: i)
end
assessment.save!

Assessment.create!(
  developer: palak,
  author: lead,
  career_level: "senior",
  title: "Palak — Senior checkpoint",
  summary: "Frontend bar is high; mentor juniors more deliberately.",
  assessed_on: Date.current - 10,
  assessment_criteria_attributes: Assessment::DEFAULT_CRITERIA.each_with_index.map { |name, i|
    { name: name, rating: [4, 5, 4, 4, 5][i], position: i, notes: nil }
  }
)

[
  { title: "Prep Bacancy demo script", description: "Outline happy path + fallbacks", developer: himanshu, assignee: lead, created_by: lead, status: "todo", priority: "high", due_on: Date.current + 3, position: 0 },
  { title: "Shadow mid assessment criteria", description: "Review Himanshu mid scores before 1:1", developer: himanshu, assignee: lead, created_by: lead, status: "in_progress", priority: "medium", due_on: Date.current + 5, position: 0 },
  { title: "Novatro a11y pass", description: "Keyboard nav on billing tables", developer: palak, assignee: lead, created_by: admin, status: "todo", priority: "medium", due_on: Date.current + 10, position: 1 },
  { title: "Book dental appointment", description: "Personal reminder", developer: nil, assignee: lead, created_by: lead, status: "todo", priority: "low", due_on: Date.current + 14, position: 2 },
  { title: "Update resume projects", description: nil, developer: nil, assignee: dev_user, created_by: dev_user, status: "in_progress", priority: "low", due_on: Date.current + 21, position: 0 },
  { title: "Practice system design notes", description: "Focus on caching patterns", developer: himanshu, assignee: dev_user, created_by: lead, status: "todo", priority: "medium", due_on: Date.current + 7, position: 1 },
].each { |attrs| ActionItem.create!(attrs) }

# ---------- Rates, allocations, growth plans, 1:1s ----------
cost_by_name = {
  "Yashika Vijayvargiya" => 1800, "Himanshu Rai" => 1400, "Palak Patel" => 1500,
  "Devendra Verma" => 1600, "Anand Paradkar" => 1550, "Parth Patki" => 1200,
  "Sakshi Chouhan" => 900, "Jay Thakur" => 800, "RamKrishan Patidar" => 850,
  "Aditya Pandit" => 1700, "Sanskar Gupta" => 1300, "Mamta Rajawat" => 1100, "Himanshi Joshi" => 1100
}
cost_by_name.each { |name, cost| by_name[name]&.update!(hourly_cost: cost) }

rate_by_project = {
  "Novatro" => 2200, "Bacancy" => 2100, "Matrix One" => 2300, "Ecosmob" => 2000,
  "Svitla / Coupa" => 2150, "New Bridge Fintech" => 2000, "Aaxis" => 1900
}
rate_by_project.each { |name, rate| projects_by_name[name]&.update!(hourly_rate: rate) }

# Seed allocations from current project roles
Project.find_each do |project|
  start = project.start_date || Date.current.beginning_of_month
  if project.main_developer
    Allocation.create!(developer: project.main_developer, project: project, role: "main", allocation_pct: 80, start_on: start)
  end
  if project.helper_developer
    Allocation.create!(developer: project.helper_developer, project: project, role: "helper", allocation_pct: 40, start_on: start)
  end
  if project.call_developer && project.call_developer_id != project.main_developer_id
    Allocation.create!(developer: project.call_developer, project: project, role: "call", allocation_pct: 20, start_on: start)
  end
end

himanshu_plan = GrowthPlan.create!(
  developer: himanshu,
  owner: lead,
  assessment: assessment,
  title: "Himanshu mid → senior track",
  target_career_level: "senior",
  goals: "Own discovery on client calls.\nLead one mid-size feature end-to-end.\nMentor Jay on PR quality.",
  focus_areas: "Client communication\nSystem design\nMentorship",
  next_review_on: Date.current + 21,
  status: "active"
)

ooo = OneOnOne.create!(
  developer: himanshu,
  conductor: lead,
  growth_plan: himanshu_plan,
  assessment: assessment,
  meeting_on: Date.current - 7,
  next_review_on: Date.current + 14,
  status: "completed",
  goals: "Tighten discovery questions; ship Ecosmob RN polish.",
  notes: "Strong week. Next: shadow Yashika on a pricing call."
)
ooo.create_action_items_from_lines!(
  ["Draft discovery checklist for Bacancy", "Book system design practice with Aditya"],
  created_by: lead
)

OneOnOne.create!(
  developer: palak,
  conductor: lead,
  meeting_on: Date.current + 3,
  next_review_on: Date.current + 17,
  status: "scheduled",
  goals: "Mentoring plan for juniors on Novatro.",
  notes: nil
)

GrowthPlan.create!(
  developer: palak,
  owner: lead,
  title: "Palak senior leadership",
  target_career_level: "lead",
  goals: "Run frontend guild.\nOwn Novatro delivery quality bar.",
  focus_areas: "Leadership\nAccessibility",
  next_review_on: Date.current + 30,
  status: "active"
)

puts "Done. Developers: #{Developer.count}, Skills: #{Skill.count}, Projects: #{Project.count}, Billings: #{ProjectBilling.count}, Client leads: #{ClientLead.count}, Users: #{User.count}, Feedbacks: #{Feedback.count}, Assessments: #{Assessment.count}, Action items: #{ActionItem.count}, Allocations: #{Allocation.count}, Growth plans: #{GrowthPlan.count}, 1:1s: #{OneOnOne.count}"
puts "Login: admin@teamtracker.test / password123 (also manager@, lead@, developer@)"
puts "Team lead #{yashika_lead.email} has #{yashika_lead.team_developers.count} assigned developers"

