json.summary "Clients see #{@setting.shown_cards.map { ClientDashboard::Setting::CARDS[it].first.downcase }.to_sentence.presence || "no cards"} on arriving in the portal"
json.greeting @setting.greeting_line
json.due_days @setting.due_days
json.recent_days @setting.recent_days
json.cards @setting.ordered_cards do |key|
  json.key key
  json.title ClientDashboard::Setting::CARDS[key].first
  json.holds ClientDashboard::Setting::CARDS[key].last
  json.shown @setting.shown?(key)
end
