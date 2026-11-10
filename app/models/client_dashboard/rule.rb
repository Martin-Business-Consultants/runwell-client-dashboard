module ClientDashboard
  # Who hears about what, for one client: a person, a kind of notice, and a level. The core says
  # who would usually hear and who could at all (Notice); a rule makes someone always hear, or
  # never. "As usual" is no row. Two sides: the client's people, emailed (Notice::CLIENT_KINDS),
  # and the team's, notified (Notice::TEAM_KINDS).
  class Rule < ApplicationRecord
    self.table_name = "client_dashboard_rules"

    LEVELS = { "always" => "Always", "usual" => "As usual", "never" => "Never" }.freeze
    SIDES = { "client" => Notice::CLIENT_KINDS, "team" => Notice::TEAM_KINDS }.freeze
    # A column's heading on a client's tab: the kind in a word or two (the core's sentence is its tooltip).
    HEADINGS = { "client.reply" => "Messages", "client.taken_on" => "Picked up", "client.done" => "Done", "client.document" => "Files",
                 "team.request" => "Requests", "team.reply" => "Messages" }.freeze
    KINDS = SIDES.flat_map { |side, kinds| kinds.keys.map { "#{side}.#{it}" } }.freeze

    class Refused < StandardError; end

    belongs_to :client
    belongs_to :user

    validates :kind, inclusion: { in: KINDS }
    validates :level, inclusion: { in: %w[always never] }

    class << self
      # The plugin's answer to the core (Runwell::Plugins.notices): everyone set to always, plus
      # the usual ones not set to never. Without a client (a request from someone not on file)
      # there are no rules to apply.
      def choose(side, kind, client:, usual:, everyone:)
        return usual unless client

        levels = where(client_id: client.id, kind: "#{side}.#{kind}").pluck(:user_id, :level).to_h
        return usual if levels.empty?

        everyone.select { |person| levels[person.id] == "always" || (levels[person.id].nil? && usual.include?(person)) }
      end

      # A client's rules as { [user_id, kind] => level }, for its page.
      def levels_for(client) = where(client_id: client.id).pluck(:user_id, :kind, :level).to_h { |user_id, kind, level| [ [ user_id, kind ], level ] }

      # Sets one person's level for one kind of notice on a client, and says so in its history.
      # The person is one of the client's own for its side, or one of the team for the team's.
      def set!(client:, person:, kind:, level:)
        side = kind.to_s.split(".").first
        raise Refused, "There’s no notice called #{kind}: one of #{KINDS.to_sentence}." unless kind.to_s.in?(KINDS)
        raise Refused, "The level is one of #{LEVELS.keys.to_sentence}." unless level.to_s.in?(LEVELS.keys)
        raise Refused, "#{person.display_name} isn’t one of #{client.name}’s people." if side == "client" && !(person.client? && person.client_id == client.id)
        raise Refused, "#{person.display_name} isn’t on the team." if side == "team" && (person.client? || person.agent?)

        rule = find_or_initialize_by(client_id: client.id, user_id: person.id, kind: kind.to_s)
        was = rule.persisted? ? rule.level : "usual"
        return rule if was == level.to_s

        transaction do
          level.to_s == "usual" ? rule.destroy! : rule.update!(level: level.to_s)
          client.record_event!("client.notices_changed", payload: { person: person.display_name, kind: kind.to_s, from: was, to: level.to_s })
        end
        rule
      end
    end
  end
end
