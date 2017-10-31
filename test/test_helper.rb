require 'active_record'
require_relative '../lib/smart_collection'
require 'database_cleaner'
require 'minitest'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

Dir.glob("#{File.dirname(__FILE__)}/models/*.rb").each do |model|
  require_relative model
end

DatabaseCleaner.strategy = :truncation

module SmartCollection
  class Test < ::Minitest::Test
    def teardown
      DatabaseCleaner.clean
    end
  end
end