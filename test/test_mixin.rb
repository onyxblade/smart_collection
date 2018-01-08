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
      item_class: 'Catalog'
    )
  end

  def test_mixin
    assert_equal Product, ProductCollection.reflect_on_association(:products).klass
    assert_equal Catalog, CatalogCollection.reflect_on_association(:catalogs).klass
  end
end
