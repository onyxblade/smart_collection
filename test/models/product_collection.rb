ActiveRecord::Base.connection.create_table(:product_collections, force: true) do |t|
  t.string :name
  t.text :rule
  t.timestamps
end

ActiveRecord::Base.connection.create_table(:product_collection_items, force: true) do |t|
  t.integer :product_collection_id
  t.integer :product_id
  t.timestamps
end

class ProductCollection < ActiveRecord::Base
  serialize :rule, JSON

  include SmartCollection::Mixin.new(
    items: :products,
    item_class: 'Product'
  )
end

class ProductCollectionRule < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :product_collection
  belongs_to :target, polymorphic: true
end

class ProductCollectionItem < ActiveRecord::Base
  belongs_to :product_collection
  belongs_to :product
end