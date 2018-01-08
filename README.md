# smart_collection

An ActiveRecord plugin that allows you to create collections by rules.

Install
------

Add `gem 'smart_collection'` to your Gemfile and `bundle`.

Usage
------

Define a collection model:
```ruby
ActiveRecord::Base.connection.create_table(:collections) do |t|
  t.text :rule
  t.datetime :cache_expires_at
  t.timestamps
end

class Collection < ActiveRecord::Base
  serialize :rule, JSON

  include SmartCollection::Mixin.new(
    items: :products,
    item_class: 'Product'
  )
end
```

Create a collection:
```ruby
collection = Collection.create(
  rule: {
    and: [
      {
        or: [
          {
            association: {
              class_name: 'Catalog',
              id: @pen_catalog.id,
              source: 'products'
            }
          },
          {
            association: {
              class_name: 'Catalog',
              id: @pencil_catalog.id,
              source: 'products'
            }
          }
        ]
      },
      {
        condition: {
          joins: 'properties',
          where: {
            properties: {
              value: 'Red'
            }
          }
        }
      }
    ]
  }
)
```

Fetch products by rules:
```ruby
collection.products #=> products associated with pen_catalog and pencil_catalog that are red
collection.products.order(id: :desc).limit(1) #=> fetch last one
```

Cache
------
Cache allows you to use preload to avoid n+1 queries.

Modify the model to:
```ruby
# use table for cache
class Collection < ActiveRecord::Base
  serialize :rule, JSON

  include SmartCollection::Mixin.new(
    items: :products,
    item_class: 'Product',
    cached_by: {
      table: :default,
      expires_in: 1.hour
    }
  )
end

# use cache store for cache
class Collection < ActiveRecord::Base
  serialize :rule, JSON

  include SmartCollection::Mixin.new(
    items: :products,
    item_class: 'Product',
    cached_by: {
      cache_store: Rails.cache,
      expires_in: 1.hour
    }
  )
end
```

Create a table if you are using table for cache:
```ruby
ActiveRecord::Base.connection.create_table(:smart_collection_cached_items) do |t|
  t.integer :collection_id
  t.integer :item_id
end
```

Use preload:
```ruby
Collection.where(id: [1, 2]).includes(products: :properties)
```

Test
------
```shell
bundle
bundle rake
```

License
------

[The MIT License](https://opensource.org/licenses/MIT)
