# frozen_string_literal: true

# JsonClientSearchService is responsible for loading and searching client records
# from a JSON file. It supports:
# - Field-specific and global search using partial, case-insensitive matching.
# - Identifying duplicate records based on a given field (e.g., email).
class JsonClientSearchService
  class InvalidJsonFormatError < StandardError; end

  def initialize(file_path: nil)
    path = file_path || ENV.fetch("CLIENTS_JSON_PATH") { Rails.root.join("lib/data/clients.json") }
    @clients = load_json(path)
  end

  # Performs a search on the loaded client dataset.
  #
  # @param field [String, nil] (optional) the specific field to search by.
  #        If nil, a global search is performed across all fields.
  # @param query [String] the search term to look for (case-insensitive, partial match).
  #
  # @return [Array<Hash>] an array of client hashes that match the search criteria.
  #
  def search(field: nil, query:)
    query_downcased = query.to_s.downcase

    if global_search?(field)
      search_all_fields(query_downcased)
    else
      search_by_field(field.to_s, query_downcased)
    end
  end

  # Finds duplicate client records based on a given field.
  #
  # @param field [String] the field to check for duplicate values (default: "email").
  #
  # @return [Array<Hash>] an array of client hashes that share the same value for the specified field.
  #
  def duplicates(field: "email")
    valid_clients = @clients.select { |client| client[field].present? }
    groups = valid_clients.group_by { |client| client[field] }
    groups.select { |_, group| group.size > 1 }
  end

  private
  def global_search?(field)
    field.nil?
  end

  def search_all_fields(query_downcased)
    @clients.select do |client|
      client.values.any? { |value| value_matches?(value, query_downcased) }
    end
  end

  def search_by_field(field, query_downcased)
    @clients.select do |client|
      value_matches?(client[field], query_downcased)
    end
  end

  def value_matches?(value, query_downcased)
    value.to_s.downcase.include?(query_downcased)
  end

  def load_json(path)
    raw_data = File.read(path)
    parsed = JSON.parse(raw_data)

    unless parsed.is_a?(Array) && parsed.all? { |item| item.is_a?(Hash) }
      raise InvalidJsonFormatError, "JSON file must be an array of objects"
    end

    parsed
    rescue Errno::ENOENT
      raise "JSON file not found at #{path}"
    rescue JSON::ParserError => e
      raise "JSON parsing error: #{e.message}"
  end
end
