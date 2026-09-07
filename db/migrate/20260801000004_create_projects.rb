class CreateProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.string :status, null: false, default: "active"
      t.string :technology
      t.references :call_developer, foreign_key: { to_table: :developers }, null: true
      t.references :main_developer, foreign_key: { to_table: :developers }, null: true
      t.references :helper_developer, foreign_key: { to_table: :developers }, null: true

      t.timestamps
    end
  end
end
