ActiveRecord::Base.connection.create_table(:product_collections, force: true) do |t|
  t.string :name
  t.text :rule
  t.datetime :cache_expires_at
  t.timestamps
end

ActiveRecord::Base.connection.create_table(:product_collection_items, force: true) do |t|
  t.integer :product_collection_id
  t.integer :product_id
  t.timestamps
end

ActiveRecord::Base.connection.create_table(:smart_collection_cached_items, force: true) do |t|
  t.integer :collection_id
  t.integer :item_id
end

class SmartCollection::CachedItem < ActiveRecord::Base
  self.table_name = :smart_collection_cached_items
  belongs_to :item
end

class ProductCollection < ActiveRecord::Base
  serialize :rule, JSON

  include SmartCollection::Mixin.new(
    items: :products,
    item_class: 'Product',
    cached_by: {
      table: true,
      expires_in: 1.hour
    }
  )
end

class ProductCollectionCachedByTable < ActiveRecord::Base
  self.table_name = 'product_collections'
  serialize :rule, JSON

  include SmartCollection::Mixin.new(
    items: :products,
    item_class: 'Product',
    cached_by: {
      table: true,
      expires_in: 1.hour
    }
  )
end

class ProductCollectionCachedByCacheStore < ActiveRecord::Base
  self.table_name = 'product_collections'
  serialize :rule, JSON

  include SmartCollection::Mixin.new(
    items: :products,
    item_class: 'Product',
    cached_by: {
      cache_store: ActiveSupport::Cache::MemoryStore.new,
      expires_in: 1.hour
    }
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
