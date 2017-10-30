ActiveRecord::Base.connection.create_table(:stock_keeping_units, force: true) do |t|
  t.string :model
  t.timestamps
end

ActiveRecord::Base.connection.create_table(:products_stock_keeping_units, force: true) do |t|
  t.integer :product_id
  t.integer :stock_keeping_unit_id
end

class StockKeepingUnit < ActiveRecord::Base
  has_and_belongs_to_many :products
end