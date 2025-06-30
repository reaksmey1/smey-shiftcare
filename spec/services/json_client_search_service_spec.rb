require 'rails_helper'

RSpec.describe JsonClientSearchService do
  let(:valid_path) { Rails.root.join("spec/fixtures/files/clients.json") }

  describe "#initialize" do
    it "loads the clients from a valid JSON file" do
      service = described_class.new(file_path: valid_path)
      expect(service.instance_variable_get(:@clients).size).to eq(35)
    end

    it "raises error if file is missing" do
      expect {
        described_class.new(file_path: Rails.root.join("invalid/path.json"))
      }.to raise_error(RuntimeError, /JSON file not found/)
    end

    it "raises error if file contains invalid JSON" do
      path = Rails.root.join("spec/fixtures/files/invalid_json.json")
      File.write(path, "{ invalid: json }")

      expect {
        described_class.new(file_path: path)
      }.to raise_error(RuntimeError, /JSON parsing error/)

      File.delete(path)
    end

    it "raises error if JSON is not an array of hashes" do
      path = Rails.root.join("spec/fixtures/files/invalid_structure.json")
      File.write(path, '{"foo":"bar"}')

      expect {
        described_class.new(file_path: path)
      }.to raise_error(JsonClientSearchService::InvalidJsonFormatError)

      File.delete(path)
    end
  end

  describe "#search" do
    subject(:service) { described_class.new(file_path: valid_path) }

    context "global search" do
      it "finds a client when query matches any field" do
        results = service.search(query: "doe")
        expect(results.map { |c| c["full_name"] }).to include("John Doe")
      end

      it "returns empty when query matches no field" do
        results = service.search(query: "xyz")
        expect(results).to be_empty
      end
    end

    context "field-specific search" do
      it "finds matching clients by full_name" do
        results = service.search(field: "full_name", query: "Jane")
        expect(results.first["email"]).to eq("jane.smith@yahoo.com")
      end

      it "is case-insensitive" do
        results = service.search(field: "full_name", query: "jOhN")
        expect(results.size).to eq(2)
      end

      it "returns empty array if field doesn't exist" do
        results = service.search(field: "not_a_field", query: "anything")
        expect(results).to be_empty
      end
    end
  end

  describe "#duplicates" do
    subject(:service) { described_class.new(file_path: valid_path) }

    it "returns clients with duplicate emails" do
      duplicates = service.duplicates
      emails = duplicates.map { |c| c["email"] }
      expect(emails.count("john.doe@gmail.com")).to eq(2)
    end

    it "returns empty array if there are no duplicates" do
      results = service.duplicates(field: "id")
      expect(results).to be_empty
    end
  end
end
