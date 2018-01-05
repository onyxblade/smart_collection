require_relative './test_helper'
require 'minitest/autorun'

class TestCache < SmartCollection::Test
  def setup
    @catalog_a = Catalog.create
    @catalog_b = Catalog.create

    @product_a = @catalog_a.products.create(price: 10)
    @product_b = @catalog_b.products.create(price: 20)

    @collection = ProductCollectionCachedByTable.create
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
  end

  def test_cache
    @collection.update_cache

    assert_includes @collection.cached_products, @product_a
    assert_includes @collection.cached_products, @product_b

    assert_includes @collection.cached_products.to_a, @product_a
    assert_includes @collection.cached_products.to_a, @product_b
  end

  def test_auto_update_cache
    @collection.expire_cache

    assert_includes @collection.products.to_a, @product_a
    assert_includes @collection.products.to_a, @product_b

    assert_includes @collection.cached_products.to_a, @product_a
    assert_includes @collection.cached_products.to_a, @product_b
  end
end
