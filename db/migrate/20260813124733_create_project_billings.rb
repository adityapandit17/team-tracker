class CreateProjectBillings < ActiveRecord::Migration[7.1]
  def change
    create_table :project_billings do |t|
      t.references :project, null: false, foreign_key: true
      t.date :billing_month, null: false
      t.decimal :hours_billed, precision: 8, scale: 2, null: false, default: 0
      t.decimal :amount, precision: 12, scale: 2
      t.string :status, null: false, default: "pending"
      t.text :notes

      t.timestamps
    end

    add_index :project_billings, [:project_id, :billing_month], unique: true
    add_index :project_billings, :status
  end
end
