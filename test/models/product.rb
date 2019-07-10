ActiveRecord::Base.connection.create_table(:products, force: true) do |t|
  t.string :name
  t.float :price
  t.timestamps
end

class Product < ActiveRecord::Base
end
