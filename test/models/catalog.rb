ActiveRecord::Base.connection.create_table(:catalogs, force: true) do |t|
  t.string :name
  t.timestamps
end

class Catalog < ActiveRecord::Base
  has_many :products
end