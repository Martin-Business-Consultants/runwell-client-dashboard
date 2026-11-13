module ClientDashboard
  # What a client sees on arriving in the portal, and who hears about what (README.md). It owns its
  # tables (client_dashboard_settings, client_dashboard_rules), points at core records by id, and
  # reaches the core only through the plugin contract (docs/plugin-contract.md in Runwell). Remove
  # it and Runwell runs as before: the portal opens on the client's work, and notices go to whoever
  # the core would usually tell.
  class Engine < ::Rails::Engine
    # Routes join the app's route set (as client_dashboard_*), so the core layout's helpers work.
    initializer "client_dashboard.routes" do |app|
      app.routes.append do
        scope "client-dashboard", module: "client_dashboard", as: "client_dashboard" do
          resource :settings, only: %i[show update]
          resources :card_moves, only: :create
          resources :clients, only: [] do
            resource :rules, only: %i[show update]
          end
        end
        scope "portal", module: "client_dashboard/portal", as: "client_dashboard_portal" do
          resource :dashboard, only: :show
        end
      end
    end

    initializer "client_dashboard.models" do
      ActiveSupport.on_load(:runwell_client) { has_many :client_dashboard_rules, class_name: "ClientDashboard::Rule", dependent: :delete_all }
      ActiveSupport.on_load(:runwell_user) { has_many :client_dashboard_rules, class_name: "ClientDashboard::Rule", dependent: :delete_all }
    end

    config.to_prepare do
      Runwell::Plugins.register :client_dashboard, name: "Client dashboard", version: ClientDashboard::VERSION, author: "Martin Business Consultants",
        enabled_by_default: false, requires: ">= 6.0.0", homepage: "https://github.com/Martin-Business-Consultants/runwell-client-dashboard",
        description: "What a client sees on arriving in the portal: new messages, what's coming up, their requests, new files and what was finished, in the cards and order you choose. And, on each client, who hears about what: which of their people are emailed for a message, a request picked up or done, or a file, and who on your team is told when they ask or write."
      Runwell::Plugins.slot :portal_dashboard, :client_dashboard, "client_dashboard/slots/portal_dashboard"
      Runwell::Plugins.slot :client_panel, :client_dashboard, "client_dashboard/slots/client_panel"
      Runwell::Plugins.stylesheet :client_dashboard, "client_dashboard/client_dashboard"
      Runwell::Plugins.settings :client_dashboard, "Client dashboard", -> { client_dashboard_settings_path if can?(:manage_settings) }
      # Who hears about what, per client (ClientDashboard::Rule): always, as usual, or never.
      Runwell::Plugins.notices :client_dashboard,
        client: ->(kind:, client:, usual:, everyone:, **) { ClientDashboard::Rule.choose("client", kind, client: client, usual: usual, everyone: everyone) },
        team: ->(kind:, client:, usual:, everyone:, **) { ClientDashboard::Rule.choose("team", kind, client: client, usual: usual, everyone: everyone) }
    end
  end
end
