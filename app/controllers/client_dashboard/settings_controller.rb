module ClientDashboard
  # Settings › Plugins › Client dashboard, for whoever manages settings: which cards a client sees
  # on arriving in the portal, the line under the greeting, and how far the cards look ahead and
  # back. Their order is CardMovesController's.
  class SettingsController < ApplicationController
    allow_staff
    require_permission :manage_settings
    agent_tool :show_client_dashboard_settings, on: :show, title: "Show the client dashboard's settings",
      description: "The cards a client sees on arriving in the portal, in order, with which are shown; the line under the greeting; and how many days the cards look ahead (due_days) and back (recent_days)."
    agent_tool :update_client_dashboard_settings, on: :update, title: "Change the client dashboard's settings",
      description: "shown: the cards clients see (the rest are switched off), from messages, due, requests, documents, done. greeting: the line under “Hello, name” (blank for the usual). due_days: how far ahead Coming up looks (1 to 90). recent_days: how far back New documents and Recently done look (1 to 365). move_client_dashboard_card changes the order.",
      params: { setting: { shown: "string[]", greeting: "string", due_days: "integer", recent_days: "integer" } }, next_tools: %i[show_client_dashboard_settings]

    def show
      @setting = Setting.current
    end

    def update
      @setting = Setting.current
      if @setting.update(params.expect(setting: [ :greeting, :due_days, :recent_days, shown: [] ]))
        redirect_to client_dashboard_settings_path, notice: "The client dashboard’s settings are saved."
      else
        render :show, status: :unprocessable_entity
      end
    end
  end
end
