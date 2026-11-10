json.summary "Who hears about what for #{@client.name}: #{pluralize @levels.size, "rule"} set, everyone else as usual"
json.client agent_ref(@client)
json.kinds ClientDashboard::Rule::SIDES.flat_map { |side, kinds| kinds.map { |kind, name| { kind: "#{side}.#{kind}", name: name } } }
json.their_people @contacts do |contact|
  json.merge! agent_ref(contact)
  json.levels Notice::CLIENT_KINDS.keys.to_h { [ "client.#{it}", @levels.fetch([ contact.id, "client.#{it}" ], "usual") ] }
end
json.team @people do |person|
  json.merge! agent_ref(person)
  json.levels Notice::TEAM_KINDS.keys.to_h { [ "team.#{it}", @levels.fetch([ person.id, "team.#{it}" ], "usual") ] }
end
