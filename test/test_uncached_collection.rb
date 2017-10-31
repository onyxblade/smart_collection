require_relative './test_helper'
require 'minitest/autorun'

class TestUncachedCollection < SmartCollection::Test
  def setup
    @catalog_a = Catalog.create
    @catalog_b = Catalog.create

    @product_a = @catalog_a.products.create
    @product_b = @catalog_b.products.create

    @collection = ProductCollection.create
    @collection.rule = {
      or: [
        {
          type: :include,
          target_type: 'Catalog',
          target_id: @catalog_a.id,
          target_association: :products
        },
        {
          type: :include,
          target_type: 'Catalog',
          target_id: @catalog_b.id,
          target_association: :products
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
end
