require_relative './test_helper'
require 'minitest/autorun'

class TestUncachedCollection < SmartCollection::Test
  def setup
    @catalog_a = Catalog.create
    @catalog_b = Catalog.create

    @product_a = @catalog_a.products.create(price: 10)
    @product_b = @catalog_b.products.create(price: 20)

    @collection = ProductCollection.create
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

  def test_includes
    assert_includes @collection.products, @product_a
    assert_includes @collection.products, @product_b

    assert_includes @collection.products.to_a, @product_a
    assert_includes @collection.products.to_a, @product_b
  end

  def test_order
    ordered = @collection.products.order(id: :desc).to_a
    assert_equal ordered.sort_by(&:id).reverse, ordered
  end

  def test_limit
    assert @collection.products.size > 1
    assert_equal 1, @collection.products.limit(1).size
  end

  def test_where
    whered = @collection.products.where(id: @product_b.id)
    assert_equal 1, whered.size
    assert_equal @product_b, whered.first
  end

  def test_preload
    assert_raises do
      ProductCollection.preload(:products).find(@collection.id)
    end
  end

  def test_eager_load
    assert_raises do
      ProductCollection.eager_load(:products).find(@collection.id)
    end
  end

  def test_condition
    collection_b = ProductCollection.create(rule: {
      and: [
        {
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
        },
        condition: {
          field: 'price',
          operator: 'lt',
          value: 20
        }
      ]
    })

    assert !(collection_b.products.include? @product_b)
    assert_includes collection_b.products, @product_a
  end

  def test_collection_of_collection
    collection_c = ProductCollection.create(rule: {
      association: {
        class_name: 'ProductCollection',
        id: @collection.id,
        source: 'products'
      }
    })

    assert_includes collection_c.products, @product_a
    assert_includes collection_c.products, @product_b
  end
end
