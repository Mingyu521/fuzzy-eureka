require "json"

seed_file = Rails.root.join("db", "seed_data", "saas-demo.json")
data = JSON.parse(File.read(seed_file))

project = Project.find_or_create_by!(name: data["project"]["name"])
puts "Project: #{project.name} (#{project.id})"
puts "API key: #{project.api_key}"

now = Time.current

data["events"].each do |event_data|
  event = project.events.create!(
    channel: event_data["channel"],
    title: event_data["title"],
    description: event_data["description"],
    icon: event_data["icon"],
    tags: event_data["tags"] || {}
  )
  timestamp = now - event_data["minutes_ago"].minutes
  event.update_columns(created_at: timestamp, updated_at: timestamp)
end

data["insights"].each do |insight_data|
  Insight.upsert_value!(
    project: project,
    title: insight_data["title"],
    value: insight_data["value"],
    icon: insight_data["icon"]
  )
end

puts "Seeded #{data['events'].size} events and #{data['insights'].size} insights."
puts "Visit /projects/#{project.id}/feed to see it."
