require_relative './test_helper'

class TestMixin < SmartCollection::Test

  class ProductCollection < ActiveRecord::Base
    include SmartCollection::Mixin.new(
      items: :products
    )
  end

  class CatalogCollection < ActiveRecord::Base
    include SmartCollection::Mixin.new(
      items: :catalogs,
      class_name: 'Catalog'
    )
  end

  # TODO
  def test_mixin
    #assert_equal Product, ProductCollection.reflect_on_association(:products).klass
    #assert_equal Catalog, CatalogCollection.reflect_on_association(:catalogs).klass

    assert_instance_of SmartCollection::Mixin, ProductCollection.smart_collection_mixin
  end
end
