
ActiveRecord::Base.connection.create_table(:properties, force: true) do |t|
  t.string :name
  t.string :value
  t.timestamps
end

ActiveRecord::Base.connection.create_table(:products_properties, force: true) do |t|
  t.integer :product_id
  t.integer :property_id
  t.timestamps
end

class Property < ActiveRecord::Base
  has_and_belongs_to_many :products
end
