module ClientDashboard
  # The plugin's staff pages use the core's layout, and vanish while it's switched off.
  class ApplicationController < ::ApplicationController
    layout "application"

    before_action { head :not_found unless Runwell::Plugins.enabled?(:client_dashboard) }
  end
end
