module ClientDashboard
  # A card of the client dashboard one place up or down the order clients see (its settings page).
  class CardMovesController < ApplicationController
    allow_staff
    require_permission :manage_settings
    agent_tool :move_client_dashboard_card, on: :create, title: "Move a card of the client dashboard",
      description: "card: one of messages, due, requests, documents, done. direction: up or down, one place in the order clients see.",
      params: { card: Setting::CARDS.keys, direction: %w[up down] }, next_tools: %i[show_client_dashboard_settings]

    def create
      card = params[:card].to_s
      return redirect_to(client_dashboard_settings_path, alert: "There’s no card called #{card}: one of #{Setting::CARDS.keys.to_sentence}.") unless Setting::CARDS.key?(card)

      Setting.current.move!(card, params[:direction])
      redirect_to client_dashboard_settings_path, notice: "#{Setting::CARDS[card].first} moved #{params[:direction] == "up" ? "up" : "down"}."
    end
  end
end
