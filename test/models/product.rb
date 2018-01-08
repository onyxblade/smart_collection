ActiveRecord::Base.connection.create_table(:products, force: true) do |t|
  t.string :name
  t.integer :catalog_id
  t.float :price
  t.timestamps
end

class Product < ActiveRecord::Base
  has_and_belongs_to_many :properties
  belongs_to :catalog
end
