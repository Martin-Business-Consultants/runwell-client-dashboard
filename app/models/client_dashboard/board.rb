module ClientDashboard
  # The dashboard one contact sees on arriving in the portal: the cards the install shows, in its
  # order, each with what it holds for this person's client. A card with nothing in it is left out.
  # The portal's slot and the client's agent (portal_dashboard) read the same object.
  class Board
    Card = Data.define(:key, :title, :hint, :items)
    LIMIT = 6

    attr_reader :contact, :client, :setting

    def initialize(contact, setting: Setting.current)
      @contact, @client, @setting = contact, contact.client, setting
    end

    # Who to greet: their first name, past any title ("Dr. Lena Ortiz" is Lena).
    def first_name = contact.name.to_s.sub(/\A((dr|mr|mrs|ms|mx|prof)\.?\s+)+/i, "").split.first || contact.name

    def cards = setting.shown_cards.filter_map { |key| card(key) }
    def empty? = cards.empty?
    def unread_ids = @unread_ids ||= Task.unread_discussion_ids(contact)

    private
      def card(key)
        items = send(key).to_a
        Card.new(key: key, title: Setting::CARDS.fetch(key).first, hint: hint(key), items: items) if items.any?
      end

      def hint(key)
        { "messages" => "We wrote to you on these.", "due" => "Due in the next #{days(setting.due_days)}.", "requests" => "What you’ve asked for that’s still open.",
          "documents" => "Shared in the last #{days(setting.recent_days)}.", "done" => "Finished in the last #{days(setting.recent_days)}." }.fetch(key)
      end

      def days(count) = count == 1 ? "day" : "#{count} days"
      # Only what this contact sees in the portal (the core's Contact::PortalScope).
      def shared = contact.portal_tasks

      def messages = shared.where(id: unread_ids).includes(:work).order(updated_at: :desc).limit(LIMIT)
      def due = shared.open.where(due_on: ..(Date.current + setting.due_days)).includes(:work).order(:due_on, :id).limit(LIMIT)
      def requests = shared.open.where.not(contact_id: nil).includes(:work).order(created_at: :desc).limit(LIMIT)
      def documents = contact.portal_documents.where(created_at: setting.recent_days.days.ago..).limit(LIMIT)
      def done = shared.where(status: "done", completed_at: setting.recent_days.days.ago..).includes(:work).order(completed_at: :desc).limit(LIMIT)
  end
end
