class CreateClientLeads < ActiveRecord::Migration[7.1]
  def change
    create_table :client_leads do |t|
      t.string :client_name, null: false
      t.references :assignee, foreign_key: { to_table: :developers }, null: true
      t.string :calls
      t.string :tests
      t.string :status, null: false, default: "hold"
      t.integer :rounds, default: 0
      t.text :remarks

      t.timestamps
    end
  end
end
