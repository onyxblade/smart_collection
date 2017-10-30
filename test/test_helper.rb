require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

Dir.glob('./models/*.rb').each do |model|
  require_relative model
end