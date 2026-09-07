class CreateDeveloperSkills < ActiveRecord::Migration[7.1]
  def change
    create_table :developer_skills do |t|
      t.references :developer, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true
      t.string :proficiency, null: false, default: "na"

      t.timestamps
    end
    add_index :developer_skills, [:developer_id, :skill_id], unique: true
  end
end
