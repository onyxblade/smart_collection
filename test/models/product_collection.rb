ActiveRecord::Base.connection.create_table(:product_collections, force: true) do |t|
  t.string :name
  t.timestamps
end

ActiveRecord::Base.connection.create_table(:product_collection_rules, force: true) do |t|
  t.integer :product_collection_id
  t.string :type
  t.string :target_type
  t.integer :target_id
  t.string :target_association
  t.timestamps
end

class ProductCollection < ActiveRecord::Base
  has_many :product_collection_rules

  include SmartCollection::Mixin.new -> do
    has_many :products, class_name: 'Product'
  end
end

class ProductCollectionRule < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :product_collection
  belongs_to :target, polymorphic: true
end