class CreateAudits < ActiveRecord::Migration[7.1]
  def change
    create_table :audits do |t|
      t.string :auditable_type, null: false
      t.bigint :auditable_id, null: false
      t.string :action, null: false
      t.bigint :user_id
      t.string :user_label
      t.string :record_label
      t.jsonb :audited_changes, null: false, default: {}
      t.string :ip_address
      t.string :request_uuid
      t.datetime :created_at, null: false
    end

    add_index :audits, [:auditable_type, :auditable_id, :created_at], name: "index_audits_on_auditable_and_time"
    add_index :audits, :created_at
    add_index :audits, :action
    add_index :audits, :user_id
    add_foreign_key :audits, :users, on_delete: :nullify
  end
end
