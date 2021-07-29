# smart_collection

[![Gem Version](https://badge.fury.io/rb/smart_collection.svg)](https://badge.fury.io/rb/smart_collection) [![Build Status](https://travis-ci.com/onyxblade/smart_collection.svg?branch=master)](https://travis-ci.com/onyxblade/smart_collection)

Smart collection or automated collection is [a concept putted forward by Shopify](https://help.shopify.com/en/manual/products/collections/automated-collections). Those collections automatically include or exclude items according to conditions defined by users.

This plugin allows you to define a collection as an union of multiple scopes; meanwhile preloading and inverse query are possible.

Install
------

Add `gem 'smart_collection'` to your Gemfile and `bundle`.

Usage
------

```ruby
# create collection table
class CreateCollections < ActiveRecord::Migration[5.0]
  def change
    create_table :collections do |t|
      t.datetime :cache_expires_at
      t.timestamps
    end
  end
end

# create cache table
class CreateSmartCollectionCachedItems < ActiveRecord::Migration[5.0]
  def change
    create_table :smart_collection_cached_items do |t|
      t.integer :collection_id
      t.integer :item_id
    end
  end
end

# define model
class Collection < ActiveRecord::Base
  include SmartCollection::Mixin.new(
    item_association: :products,
    item_class_name: 'Product',
    # scopes option can be a method name / proc that returns an array of scopes
    scopes: -> (collection) {
      [Product.all]
    },
    # the table :smart_collection_cached_items is used when cache_table_name setted :default
    cache_table_name: :default,
    # cache_expires_in can be a duration or a method name / proc that returns a duration
    cache_expires_in: 1.hour,
    # defines an inverse association on the item class
    inverse_association: :collections
  )
end
```

```ruby
# create a collection:
collection = Collection.create
# fetch products by defined scope
collection.products # => all products will be returned
collection.products.where(in_stock: true).order(id: :desc) #=> association returns a scope
```

```ruby
# use includes or preload to avoid n+1 queries
Collection.where(id: [1, 2]).preload(products: :properties)
```

Test
------
```shell
bundle exec rake
```

License
------

[The MIT License](https://opensource.org/licenses/MIT)
