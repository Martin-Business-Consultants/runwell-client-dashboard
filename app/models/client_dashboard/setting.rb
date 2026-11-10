module ClientDashboard
  # The dashboard's settings for the install (Settings > Plugins > Client dashboard), one row: which
  # cards a client sees and in what order, the line under the greeting, and how far the cards look
  # (due_days ahead for what's coming up, recent_days back for new files and what was finished).
  class Setting < ApplicationRecord
    self.table_name = "client_dashboard_settings"

    # Every card there is, in the order a new install shows them: its title and what it holds.
    CARDS = {
      "messages" => [ "New messages", "Tasks holding a message from you they haven’t read" ],
      "due" => [ "Coming up", "Open tasks due soon, and any that are late" ],
      "requests" => [ "Your requests", "What they asked for that’s still open, and how far each has got" ],
      "documents" => [ "New documents", "Files you shared with them lately" ],
      "done" => [ "Recently done", "What was finished lately" ]
    }.freeze
    DEFAULT_GREETING = "Here’s where things stand."

    validates :due_days, numericality: { only_integer: true, in: 1..90 }
    validates :recent_days, numericality: { only_integer: true, in: 1..365 }
    validates :greeting, length: { maximum: 200 }
    normalizes :greeting, with: ->(text) { text.to_s.squish.presence }

    def self.current = first || create!

    # Every card in the install's order: the saved order, then any card a release added since.
    def ordered_cards = (cards.to_a & CARDS.keys) | CARDS.keys
    def shown_cards = ordered_cards - hidden.to_a
    def shown?(key) = shown_cards.include?(key.to_s)
    def greeting_line = greeting.presence || DEFAULT_GREETING

    # The cards a client sees, by key: the rest are switched off. Their order stays.
    def shown=(keys)
      self.hidden = CARDS.keys - Array(keys).map(&:to_s)
    end

    # A card one place up or down the order.
    def move!(key, direction)
      order = ordered_cards
      from = order.index(key.to_s) or return
      to = (from + (direction.to_s == "up" ? -1 : 1)).clamp(0, order.size - 1)
      order.insert(to, order.delete_at(from))
      update!(cards: order)
    end
  end
end
