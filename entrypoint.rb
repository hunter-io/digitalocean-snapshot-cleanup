require 'droplet_kit'
require 'rest-client'

RestClient.get("#{ENV['CRONITOR_URL']}/run") if ENV['CRONITOR_URL'].present?

abort('[ERROR] Please provide an API_KEY') if ENV['API_KEY'].blank?

abort('[ERROR] Please provide a list of DROPLETS you want to cleanup the snapshots for') if ENV['DROPLETS'].blank?

droplets = ENV['DROPLETS'].split(',')

number_snapshots_to_keep = ENV['NUMBER_SNAPSHOTS_TO_KEEP'] || 3

snapshots = {}

droplets.each { |d| snapshots[d] = [] }

deleted_snapshots_count = 0

begin
  client = DropletKit::Client.new(access_token: ENV['API_KEY'])

  # saves the snapshots references for the provided droplets
  client.snapshots.all.each do |snapshot|
    next if droplets.exclude?(snapshot.resource_id)

    snapshots[snapshot.resource_id] << snapshot
  end

  # for each droplets, only keeps the newest "number_snapshots_to_keep" snapshots
  droplets.each do |droplet|
    snapshots_to_delete = snapshots[droplet].size - number_snapshots_to_keep

    # no snapshots to delete
    next if snapshots_to_delete <= 0

    sorted = snapshots[droplet].sort_by { |s| s[:created_at] }

    [*0..snapshots_to_delete - 1].each do |i|
      client.snapshots.delete(id: sorted[i][:id])

      deleted_snapshots_count += 1
    end
  end

  puts "Deleted #{deleted_snapshots_count} snaphot(s)"

rescue DropletKit::Error => e
  if e.message.start_with?('401')
    abort('[ERROR] Failed to cleanup snapshots, API_KEY is invalid')
  else
    abort("[ERROR] #{e.message}")
  end
end

RestClient.get("#{ENV['CRONITOR_URL']}/complete") if ENV['CRONITOR_URL'].present?
