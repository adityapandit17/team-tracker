class AddLeadIncentives < ActiveRecord::Migration[7.1]
  def change
    add_reference :projects, :lead_developer, foreign_key: { to_table: :developers }, index: true
    add_column :projects, :incentive_eligible, :boolean, null: false, default: true

    add_column :developers, :incentive_eligible, :boolean, null: false, default: false
    add_column :developers, :incentive_free_project_count, :integer, null: false, default: 0
    add_column :developers, :incentive_amount_per_project, :decimal, precision: 12, scale: 2
  end
end
