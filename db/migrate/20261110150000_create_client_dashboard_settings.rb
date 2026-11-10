# The dashboard's settings for the install, one row: its cards in order (all of them), the ones
# switched off, the line under the greeting, and how far ahead and back the cards look.
class CreateClientDashboardSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :client_dashboard_settings do |t|
      t.json :cards, default: [], null: false
      t.json :hidden, default: [], null: false
      t.string :greeting
      t.integer :due_days, default: 14, null: false
      t.integer :recent_days, default: 30, null: false
      t.timestamps
    end
  end
end
