class AddTeamLeadToDevelopers < ActiveRecord::Migration[7.1]
  def change
    add_reference :developers, :team_lead, foreign_key: { to_table: :users }, null: true
  end
end
