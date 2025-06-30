require 'rails_helper'
require 'rake'

RSpec.describe 'client_search rake tasks', type: :task do
  before(:all) do
    Rails.application.load_tasks unless Rake::Task.tasks.any?
  end

  after(:each) do
    Rake::Task['client_search:find'].reenable
    Rake::Task['client_search:duplicates'].reenable
  end

  describe 'client_search:find' do
    let(:task) { Rake::Task['client_search:find'] }
    let(:service_instance) { instance_double('JsonClientSearchService') }

    before do
      allow(JsonClientSearchService).to receive(:new).and_return(service_instance)
    end

    it 'exits and prints usage if query argument is missing' do
      expect {
        expect {
          task.invoke(nil, nil)
        }.to raise_error(SystemExit)
      }.to output(/Usage:/).to_stdout
    end

    it 'prints results if found' do
      results = [
        { 'full_name' => 'John Doe', 'email' => 'john@example.com' },
        { 'full_name' => 'Johnny Appleseed', 'email' => 'johnny@example.com' }
      ]
      allow(service_instance).to receive(:search).with(field: 'full_name', query: 'john').and_return(results)
      expect {
        task.invoke('john', 'full_name')
      }.to output(/Found 2 matching client\(s\):.*John Doe/m).to_stdout
    end

    it 'prints no matches found message if results empty' do
      allow(service_instance).to receive(:search).and_return([])

      expect {
        task.invoke('nobody', nil)
      }.to output(/No matching clients found./).to_stdout
    end
  end

  describe 'client_search:duplicates' do
    let(:task) { Rake::Task['client_search:duplicates'] }
    let(:service_instance) { instance_double('JsonClientSearchService') }

    before do
      allow(JsonClientSearchService).to receive(:new).and_return(service_instance)
    end

    it 'prints duplicates if any found' do
      duplicates_hash = {
        'dup@example.com' => [
          { 'email' => 'dup@example.com', 'full_name' => 'Alice' },
          { 'email' => 'dup@example.com', 'full_name' => 'Bob' }
        ]
      }
      allow(service_instance).to receive(:duplicates).with(field: 'email').and_return(duplicates_hash)
      expect {
        task.invoke(nil)
      }.to output(/Found duplicates by 'email':.*Duplicate: dup@example.com.*Alice/m).to_stdout
    end

    it 'prints no duplicates message when none found' do
      allow(service_instance).to receive(:duplicates).and_return({})
      expect {
        task.invoke('phone')
      }.to output(/No duplicates found for field: phone/).to_stdout
    end
  end
end
