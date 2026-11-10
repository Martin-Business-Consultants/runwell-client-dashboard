module ClientDashboard
  # Who hears about what, on one client (its Client dashboard tab): for each of the client's people
  # and each of the team, always, as usual or never, per kind of notice (ClientDashboard::Rule).
  class RulesController < ApplicationController
    allow_staff
    agent_tool :show_client_notices, on: :show, title: "Who hears about what, for a client",
      description: "For one client: each of their people who can be emailed and each person on the team, with their level (always, usual, never) for every kind of notice. Kinds for the client's people: client.reply (we write to them on a task), client.taken_on, client.done, client.document. For the team: team.request (a request comes in), team.reply (they write on a task)."
    agent_tool :set_client_notice, on: :update, title: "Set who hears about something, for a client",
      description: "user_id: one of the client's people (for a client.* kind) or someone on the team (for a team.* kind), by id or name. level: always (whatever it's about), usual (when the core would tell them anyway: it's theirs, they're on the task, or they take requests on), never. A person who switched the portal's emails off still gets none.",
      params: { rule: { user_id: "integer!", kind: Rule::KINDS, level: Rule::LEVELS.keys } }, next_tools: %i[show_client_notices]

    before_action { @client = Client.find(params[:client_id]) }

    def show
      @levels = Rule.levels_for(@client)
      @contacts = Notice.reachable_contacts(@client)
      @people = User.people.active.ordered.to_a
      respond_to do |format|
        format.json
        format.html { redirect_to main_app.client_path(@client, tab: "plugin-client_dashboard") }
      end
    end

    def update
      rule = params.expect(rule: %i[user_id kind level])
      person = User.find(rule[:user_id])
      Rule.set!(client: @client, person: person, kind: rule[:kind], level: rule[:level])
      redirect_back fallback_location: main_app.client_path(@client, tab: "plugin-client_dashboard"),
        notice: "#{person.display_name}: #{Rule::LEVELS[rule[:level]].downcase} for “#{notice_name(rule[:kind]).downcase_first}”."
    rescue Rule::Refused => error
      redirect_back fallback_location: main_app.client_path(@client, tab: "plugin-client_dashboard"), alert: error.message
    end

    private
      def notice_name(kind)
        side, name = kind.to_s.split(".")
        Rule::SIDES.fetch(side).fetch(name)
      end
  end
end
