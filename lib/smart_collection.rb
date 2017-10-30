require 'active_record'

module SmartCollection
end

Dir.glob("#{File.dirname(__FILE__)}/**/*.rb").each do |file|
  require file
end