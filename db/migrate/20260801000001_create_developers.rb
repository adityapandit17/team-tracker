class CreateDevelopers < ActiveRecord::Migration[7.1]
  def change
    create_table :developers do |t|
      t.string :name, null: false
      t.string :stack, null: false, default: "other"
      t.string :education_detail
      t.integer :passing_year
      t.boolean :b2b_eligible
      t.string :availability_status, null: false, default: "available"
      t.boolean :ready_for_new_project, default: true
      t.integer :on_call_count, default: 0
      t.decimal :rating, precision: 3, scale: 1
      t.text :notes

      t.timestamps
    end
  end
end
