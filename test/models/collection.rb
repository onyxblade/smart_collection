ActiveRecord::Base.connection.create_table(:collections, force: true) do |t|
  t.string :name
  t.text :rule
  t.datetime :cache_expires_at
  t.text :scope_ids
  t.timestamps
end

ActiveRecord::Base.connection.create_table(:smart_collection_cached_items, force: true) do |t|
  t.integer :collection_id
  t.integer :item_id
end

class Collection < ActiveRecord::Base
  serialize :scope_ids, JSON

  include SmartCollection::Mixin.new(
    item_association: :products,
    item_class_name: 'Product',
    scopes: -> (owner) {
      owner.scopes
    },
    inverse_association: :collections,
    cache_table: :default,
    cache_expires_in: 1.hour
  )

  def scopes= scopes
    self.scope_ids = scopes.map{|x| x.pluck(:id)}
  end

  def scopes
    scope_ids.map{|x| Product.where(id: x)}
  end
end