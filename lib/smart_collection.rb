require 'active_record'

module SmartCollection
  COLLECTIONS = {}
end

Dir.glob("#{File.dirname(__FILE__)}/**/*.rb").each do |file|
  require file
end