# Who hears about what, per client: a person (one of the client's, or one of the team), a kind of
# notice ("client.reply", "team.request") and always or never. No row means as usual.
class CreateClientDashboardRules < ActiveRecord::Migration[8.1]
  def change
    create_table :client_dashboard_rules do |t|
      t.integer :client_id, null: false
      t.integer :user_id, null: false
      t.string :kind, null: false
      t.string :level, null: false
      t.timestamps
    end
    add_index :client_dashboard_rules, %i[client_id kind user_id], unique: true
    add_index :client_dashboard_rules, :user_id
  end
end
