# Client dashboard (a Runwell plugin): guide for AI agents

A Rails engine loaded into a Runwell install (README.md says what it does). Run it from a Runwell
checkout with `bin/rails "plugins:link[path]"`. Read Runwell's `docs/plugin-contract.md` (use
nothing of the core's beyond it) and its `AGENTS.md` (the conventions this code follows).

## How it's built

- `ClientDashboard::Board` is the dashboard for one contact: the cards the install shows, in its
  order, each with what it holds for that person's client, empty ones left out. The portal's slot
  (`slots/_portal_dashboard`, the core's `:portal_dashboard`) and the client's agent
  (`Portal::DashboardsController`, `portal_dashboard`) read the same object; keep it that way. A
  new card is a key in `Setting::CARDS`, a private method of that name on `Board` and its hint
- `ClientDashboard::Setting` (`client_dashboard_settings`, one row): the cards' order (`cards`),
  the ones switched off (`hidden`), the greeting's line and the two windows. `ordered_cards`
  appends any card a release adds, so saved orders never need migrating
- `ClientDashboard::Rule` (`client_dashboard_rules`): per client, person and kind of notice,
  `always` or `never`; "as usual" is no row. `Rule.choose` is the plugin's answer to the core's
  `Runwell::Plugins.notices` (everyone set to always, plus the usual ones not set to never), and
  `Rule.set!` is the only way a rule changes: it refuses a person from the wrong side
  (`Rule::Refused`) and records `client.notices_changed` on the client
- The kinds are the core's (`Notice::CLIENT_KINDS`, `Notice::TEAM_KINDS`), prefixed with their side
  (`client.reply`, `team.request`): never a list of the plugin's own. A kind the core adds shows
  on the tab by itself; give it a heading in `Rule::HEADINGS`
- The tab on each client (`slots/_client_panel`) is a form per cell that saves on change
  (`RulesController#update`); agents use `show_client_notices` and `set_client_notice`

## Rules

- The plugin sends nothing itself: the core sends every notice, and only to people it says could
  hear. Don't add a mailer here for something the core already tells people about
- What a client reads goes through the core's portal helpers (`portal_task_link_to`,
  `portal_status_tag`, `portal_due`, `portal_unread_mark`): never `task.status`
- Tables are prefixed `client_dashboard_`, point at core records by id, and migrations only add
- Release: bump `lib/client_dashboard/version.rb`, commit, tag `vX.Y.Z`, push the tag
