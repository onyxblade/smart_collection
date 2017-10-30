require 'active_record'
require_relative '../lib/smart_collection'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

Dir.glob("#{File.dirname(__FILE__)}/models/*.rb").each do |model|
  require_relative model
end