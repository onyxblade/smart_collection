require_relative './test_helper'
require 'minitest/autorun'

class TestCachedByCacheStore < SmartCollection::Test
  def setup
    @catalog_a = Catalog.create
    @catalog_b = Catalog.create

    @product_a = @catalog_a.products.create(price: 10)
    @product_b = @catalog_b.products.create(price: 20)

    @collection = ProductCollectionCachedByCacheStore.create
    @collection.rule = {
      or: [
        {
          association: {
            class_name: 'Catalog',
            id: @catalog_a.id,
            source: 'products'
          }
        },
        {
          association: {
            class_name: 'Catalog',
            id: @catalog_b.id,
            source: 'products'
          }
        }
      ]
    }

    @collection.save
    @collection_b = ProductCollectionCachedByTable.create(
      rule: {
        or: [
          {
            association: {
              class_name: 'Catalog',
              id: @catalog_a.id,
              source: 'products'
            }
          }
        ]
      }
    )
  end

  def test_cache
    @collection.update_cache

    assert_includes @collection.association(:products).cached_scope, @product_a
    assert_includes @collection.association(:products).cached_scope, @product_b

    assert_includes @collection.association(:products).cached_scope.to_a, @product_a
    assert_includes @collection.association(:products).cached_scope.to_a, @product_b
  end

  def test_auto_update_cache
    @collection.expire_cache
    @collection.products.to_a

    assert @collection.cache_expires_at > Time.now

    assert_equal @collection.association(:products).cached_scope, @collection.products
    assert_equal @collection.association(:products).cached_scope.to_a, ProductCollectionCachedByCacheStore.find(@collection.id).products
  end

  def test_preload
    [@collection, @collection_b].map(&:expire_cache)

    ProductCollectionCachedByCacheStore.where(id: [@collection.id, @collection_b.id]).preload(:products).to_a

    assert_queries 2 do
      ProductCollectionCachedByCacheStore.where(id: [@collection.id, @collection_b.id]).preload(:products).map{|x| x.products.to_a}
    end

    [@collection, @collection_b].map(&:expire_cache)

    ProductCollectionCachedByCacheStore.find(@collection.id).products.to_a
    ProductCollectionCachedByCacheStore.find(@collection_b.id).products.to_a

    assert_queries 2 do
      ProductCollectionCachedByCacheStore.where(id: [@collection.id, @collection_b.id]).preload(:products).map{|x| x.products.to_a}
    end
  end

end
