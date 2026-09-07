class CreateOneOnOnesGrowthPlansAllocations < ActiveRecord::Migration[7.1]
  def change
    add_column :developers, :hourly_cost, :decimal, precision: 10, scale: 2
    add_column :projects, :hourly_rate, :decimal, precision: 10, scale: 2

    create_table :growth_plans do |t|
      t.references :developer, null: false, foreign_key: true
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.references :assessment, null: true, foreign_key: true
      t.string :title, null: false
      t.string :target_career_level
      t.text :goals
      t.text :focus_areas
      t.date :next_review_on
      t.string :status, default: "active", null: false
      t.timestamps
    end
    add_index :growth_plans, :status
    add_index :growth_plans, :next_review_on

    create_table :one_on_ones do |t|
      t.references :developer, null: false, foreign_key: true
      t.references :conductor, null: false, foreign_key: { to_table: :users }
      t.references :growth_plan, null: true, foreign_key: true
      t.references :assessment, null: true, foreign_key: true
      t.date :meeting_on, null: false
      t.text :notes
      t.text :goals
      t.date :next_review_on
      t.string :status, default: "scheduled", null: false
      t.timestamps
    end
    add_index :one_on_ones, :meeting_on
    add_index :one_on_ones, :status
    add_index :one_on_ones, :next_review_on

    create_table :allocations do |t|
      t.references :developer, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.string :role, default: "main", null: false
      t.integer :allocation_pct, default: 100, null: false
      t.date :start_on, null: false
      t.date :end_on
      t.text :notes
      t.timestamps
    end
    add_index :allocations, [:developer_id, :project_id]
    add_index :allocations, :start_on
    add_index :allocations, :end_on

    add_reference :action_items, :one_on_one, null: true, foreign_key: true
    add_reference :action_items, :growth_plan, null: true, foreign_key: true
  end
end
