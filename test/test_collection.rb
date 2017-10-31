require_relative './test_helper'
require 'minitest/autorun'

class TestCollection < SmartCollection::Test
  def test_collection
    catalog_a = Catalog.create
    catalog_b = Catalog.create

    product_a = catalog_a.products.create
    product_b = catalog_b.products.create

    collection = ProductCollection.create
    collection.product_collection_rules.create(type: 'include', target: catalog_a, target_association: 'products')
    collection.product_collection_rules.create(type: 'include', target: catalog_b, target_association: 'products')

    assert_includes collection.products, product_a
    assert_includes collection.products, product_b

    assert_includes collection.products.to_a, product_a
    assert_includes collection.products.to_a, product_b
  end
end
