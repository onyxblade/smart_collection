# smart_collection

[![Gem Version](https://badge.fury.io/rb/smart_collection.svg)](https://badge.fury.io/rb/smart_collection) [![Build Status](https://travis-ci.org/CicholGricenchos/smart_collection.svg?branch=master)](https://travis-ci.org/CicholGricenchos/smart_collection)

An ActiveRecord plugin that allows you to create collections by rules.

Install
------

Add `gem 'smart_collection'` to your Gemfile and `bundle`.

Usage
------

Define a collection model:
```ruby
class CreateCollections < ActiveRecord::Migration[5.0]
  def change
    create_table :collections do |t|
      t.text :rule # You can use other implements here, but be sure rule returns a hash
      t.datetime :cache_expires_at
      t.timestamps
    end
  end
end

class Collection < ActiveRecord::Base
  serialize :rule, JSON

  include SmartCollection::Mixin.new(
    items: :products,
    class_name: 'Product' # Optional
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
collection.products #=> products that are red and associated with pen_catalog and pencil_catalog
collection.products.where(in_stock: true).order(id: :desc) #=> association returns a scope
```

You are free to use ActiveRecord style `joins` and `where` arguments in `condition` clause.

Cache
------
Cache allows you to use `preload` to avoid n+1 queries, like:

```ruby
Collection.where(id: [1, 2]).preload(products: :properties)
```

### Use table for cache
Create a cache item table:
```ruby
class CreateSmartCollectionCachedItems < ActiveRecord::Migration[5.0]
  def change
    create_table :smart_collection_cached_items do |t|
      t.integer :collection_id
      t.integer :item_id
    end
  end
end
```

By default, this cache table is shared. So there's no need to create cache table per collection.

Modify the model to:
```ruby
class Collection < ActiveRecord::Base
  serialize :rule, JSON

  include SmartCollection::Mixin.new(
    items: :products,
    cached_by: {
      table: :default,
      expires_in: 1.hour
    }
  )
end
```

### Use cache store for cache
Modify the model to:
```ruby
class Collection < ActiveRecord::Base
  serialize :rule, JSON

  include SmartCollection::Mixin.new(
    items: :products,
    cached_by: {
      cache_store: Rails.cache,
      expires_in: 1.hour
    }
  )
end
```

Test
------
```shell
bundle rake
```

License
------

[The MIT License](https://opensource.org/licenses/MIT)
