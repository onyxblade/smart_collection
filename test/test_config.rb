require_relative './test_helper'

class TestConfig < SmartCollection::Test

  def test_cache_expires_in_proc
    klass = Class.new ActiveRecord::Base do
      self.table_name = 'collections'
      include SmartCollection::Mixin.new(
        item_association: :products,
        item_class_name: 'Product',
        cache_table: :default,
        scopes: :scopes,
        cache_expires_in: 1.hour
      )
    end
    assert_equal 1.hour, klass.smart_collection_mixin.config.cache_expires_in_proc.(nil)

    klass = Class.new ActiveRecord::Base do
      self.table_name = 'collections'
      include SmartCollection::Mixin.new(
        item_association: :products,
        item_class_name: 'Product',
        cache_table: :default,
        scopes: :scopes,
        cache_expires_in: -> (owner) { 1.hour }
      )
    end
    assert_equal 1.hour, klass.smart_collection_mixin.config.cache_expires_in_proc.(nil)

    klass = Class.new ActiveRecord::Base do
      self.table_name = 'collections'
      include SmartCollection::Mixin.new(
        item_association: :products,
        item_class_name: 'Product',
        cache_table: :default,
        scopes: :scopes,
        cache_expires_in: :cache_expires_in
      )
    end
    mock = Object.new
    mock.define_singleton_method(:cache_expires_in){ 1.hour }
    assert_equal 1.hour, klass.smart_collection_mixin.config.cache_expires_in_proc.(mock)
  end

  def test_scopes_proc
    klass = Class.new ActiveRecord::Base do
      self.table_name = 'collections'
      include SmartCollection::Mixin.new(
        item_association: :products,
        item_class_name: 'Product',
        cache_table: :default,
        scopes: -> (owner) { [1, 2, 3] },
        cache_expires_in: 1.hour
      )
    end
    assert_equal [1, 2, 3], klass.smart_collection_mixin.config.scopes_proc.(nil)

    klass = Class.new ActiveRecord::Base do
      self.table_name = 'collections'
      include SmartCollection::Mixin.new(
        item_association: :products,
        item_class_name: 'Product',
        cache_table: :default,
        scopes: :scopes,
        cache_expires_in: 1.hour
      )
    end
    mock = Object.new
    mock.define_singleton_method(:scopes){ [1, 2, 3] }
    assert_equal [1, 2, 3], klass.smart_collection_mixin.config.scopes_proc.(mock)
  end

end
