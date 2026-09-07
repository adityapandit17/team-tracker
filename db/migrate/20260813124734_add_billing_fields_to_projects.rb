class AddBillingFieldsToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :start_date, :date
    add_column :projects, :billing_type, :string, null: false, default: "monthly"
    add_column :projects, :fixed_amount, :decimal, precision: 12, scale: 2
  end
end
