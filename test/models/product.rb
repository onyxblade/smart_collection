ActiveRecord::Base.connection.create_table(:products, force: true) do |t|
  t.string :name
  t.integer :catalog_id
  t.timestamps
end

class Product < ActiveRecord::Base
  has_and_belongs_to_many :stock_keeping_units
  belongs_to :catalog
end