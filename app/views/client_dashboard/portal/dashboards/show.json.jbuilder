cards = @board.cards
json.summary cards.any? ? cards.map { "#{it.title.downcase}: #{it.items.size}" }.join(", ").upcase_first : "Nothing new right now."
json.cards cards do |card|
  json.key card.key
  json.title card.title
  json.items card.items do |item|
    if item.is_a?(Document)
      json.filename item.filename.to_s
      json.shared_on item.created_at.to_date
      json.url rails_blob_url(item.file, disposition: :attachment)
    else
      json.id item.id
      json.title item.title
      json.status item.client_status
      json.due_on item.due_on
      json.late item.late?
      json.unread_messages @board.unread_ids.include?(item.id)
      json.work item.work&.title
      json.url portal_tasks_url(task: item.id, status: "all")
    end
  end
end
