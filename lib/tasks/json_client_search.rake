# lib/tasks/json_client_search.rake
namespace :client_search do
  # rake "client_search:find[john,full_name]"
  # rake "client_search:find[john]"
  desc "Search clients by field and query from a JSON file"
  task :find, [:query, :field] => :environment do |t, args|
    unless args[:query]
      puts "Usage: rake client_search:run[query,field]"
      puts "Example: rake client_search:run[john,email]"
      exit(1)
    end

    field = args[:field]
    query = args[:query]

    service = JsonClientSearchService.new
    results = service.search(field: field, query: query)

    if results.any?
      puts "Found #{results.size} matching client(s):"
      results.each do |client|
        puts client.inspect
      end
    else
      puts "No matching clients found."
    end
  end

  # rake "client_search:duplicates[email]"
  # rake "client_search:duplicates"
  desc "Find duplicate clients by a specific field (default: email)"
  task :duplicates, [:field] => :environment do |t, args|
    field = args[:field] || 'email'

    service = JsonClientSearchService.new
    duplicates = service.duplicates(field: field)
    puts duplicates
    if duplicates.any?
      puts "Found duplicates by '#{field}':"
      duplicates.each do |value, group|
        puts "\nDuplicate: #{value}"
        group.each { |client| puts client.inspect }
      end
    else
      puts "No duplicates found for field: #{field}"
    end
  end
end