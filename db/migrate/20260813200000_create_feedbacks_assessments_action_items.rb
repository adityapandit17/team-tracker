class CreateFeedbacksAssessmentsActionItems < ActiveRecord::Migration[7.1]
  def change
    create_table :feedbacks do |t|
      t.references :developer, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :body
      t.integer :rating, null: false
      t.date :feedback_date, null: false
      t.timestamps
    end

    create_table :assessments do |t|
      t.references :developer, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string :career_level, null: false
      t.string :title, null: false
      t.text :summary
      t.decimal :overall_rating, precision: 3, scale: 2
      t.date :assessed_on, null: false
      t.timestamps
    end
    add_index :assessments, :career_level

    create_table :assessment_criteria do |t|
      t.references :assessment, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :rating, null: false
      t.text :notes
      t.integer :position, default: 0, null: false
      t.timestamps
    end

    create_table :action_items do |t|
      t.references :developer, null: true, foreign_key: true
      t.references :assignee, null: false, foreign_key: { to_table: :users }
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description
      t.string :status, default: "todo", null: false
      t.string :priority, default: "medium", null: false
      t.date :due_on
      t.integer :position, default: 0, null: false
      t.timestamps
    end
    add_index :action_items, :status
    add_index :action_items, :priority
  end
end
