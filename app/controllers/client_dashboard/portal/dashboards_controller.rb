module ClientDashboard
  module Portal
    # The dashboard for a client's own agent: what the portal's first page shows the person, as
    # JSON. A person sees it on that page, so the browser is sent there.
    class DashboardsController < ::Portal::BaseController
      agent_tool :portal_dashboard, on: :show, title: "What's new for you",
        description: "What the portal shows on arriving: tasks holding a message you haven't read, what's due soon or late, your open requests, files shared lately and what was finished lately. Only the cards this business shows, in its order."

      before_action { head :not_found unless Runwell::Plugins.enabled?(:client_dashboard) }

      def show
        @board = Board.new(current_contact)
        respond_to do |format|
          format.json
          format.html { redirect_to portal_root_path }
        end
      end
    end
  end
end
