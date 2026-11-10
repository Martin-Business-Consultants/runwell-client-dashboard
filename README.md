# Client dashboard, a Runwell plugin

What a client sees on arriving in the portal, and who hears about what, for
[Runwell](https://github.com/Martin-Business-Consultants/runwellv2).

Runwell's portal opens on the client's work. This plugin puts a dashboard above it, and gives each
client a tab that decides who is told about what.

## The dashboard

At the top of the portal's first page: "Hello," and the person's first name, a line of yours, then
cards. Each shows only when it holds something:

- **New messages**: tasks holding a message from you they haven't read
- **Coming up**: open tasks due soon, and any that are late
- **Your requests**: what they asked for that's still open, and how far each has got
- **New documents**: files you shared with them lately
- **Recently done**: what was finished lately

A task opens in the portal's side sheet, with its discussion; a file opens or downloads.

In **Settings › Plugins › Client dashboard** choose which cards show and their order, the line
under the greeting, and how far the cards look (days ahead for Coming up, days back for New
documents and Recently done). To see it as a client does, open a contact and choose View as.

## Who hears about what

Each client has a **Client dashboard** tab with two tables.

**What they hear from you**: their people who use the portal, against the emails Runwell sends a
client: a message from you on a task, something they asked for picked up, something they asked for
done, and files shared with them.

**What your team hears from them**: your people, against a request coming in and a message from
the client on a task.

Each cell is one of:

- **As usual**: Runwell's own choice. A client's person hears about what they asked for or wrote
  on (files go to everyone); a request goes to owners and managers, and a client's message to
  whoever is on the task
- **Always**: every one for this client, whatever it's about. Put an account lead on Always for
  requests, or a client's office manager on Always for files
- **Never**: none of that kind, for this client

Someone at a client who switched the portal's emails off in their own account still gets none.
Every change is in the client's history.

## For AI

Connected assistants get `show_client_notices` and `set_client_notice`, the dashboard's settings
(`show_client_dashboard_settings`, `update_client_dashboard_settings`,
`move_client_dashboard_card`), and, for a client's own assistant, `portal_dashboard`: what the
dashboard shows them.

## Installing

In Runwell (5.30 or newer): **Settings › Plugins**, add
`Martin-Business-Consultants/runwell-client-dashboard`, then switch it on. Removing it leaves the
portal opening on the client's work, and notices going to whoever Runwell would usually tell; its
tables (`client_dashboard_settings`, `client_dashboard_rules`) stay.

## Developing

Clone it beside a Runwell checkout and link it: `bin/rails "plugins:link[../runwell-client-dashboard]"`,
then restart and `bin/rails db:migrate`. See AGENTS.md.

FSL-1.1-MIT, as Runwell is.
