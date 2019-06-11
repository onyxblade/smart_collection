require_relative './test_helper'

class TestCachedByCacheStore < SmartCollection::Test
  def setup
    load_fixtures
    @pen_and_pencil_collection = ProductCollectionCachedByCacheStore.find(@pen_and_pencil_collection.id)
    @pen_and_marker_collection = ProductCollectionCachedByCacheStore.find(@pen_and_marker_collection.id)
    @pen_and_pencil_products = [@pen_catalog.products, @pencil_catalog.products].flatten
    @pen_and_marker_products = [@pen_catalog.products, @marker_catalog.products].flatten
  end

  def test_update_cache
    @pen_and_pencil_collection.update_cache

    assert_equal @pen_and_pencil_products.size, @pen_and_pencil_collection.smart_collection_mixin.cached_scope(@pen_and_pencil_collection).size
    @pen_and_pencil_products.each do |product|
      assert_includes @pen_and_pencil_collection.smart_collection_mixin.cached_scope(@pen_and_pencil_collection), product
      assert_includes @pen_and_pencil_collection.smart_collection_mixin.cached_scope(@pen_and_pencil_collection).to_a, product
    end
  end

  def test_expire_cache
    @pen_and_pencil_collection.update_cache
    assert @pen_and_pencil_collection.cache_exists?
    @pen_and_pencil_collection.expire_cache
    refute @pen_and_pencil_collection.cache_exists?
  end

  def test_auto_update_cache
    @pen_and_pencil_collection.expire_cache
    @pen_and_pencil_collection.reload.products.to_a

    assert @pen_and_pencil_collection.cache_expires_at > Time.now
    assert_equal @pen_and_pencil_collection.smart_collection_mixin.cached_scope(@pen_and_pencil_collection), @pen_and_pencil_collection.reload.products
  end

  def test_preload
    [@pen_and_pencil_collection, @pen_and_marker_collection].map(&:expire_cache)

    @pen_and_pencil_collection.reload.products.to_a
    @pen_and_marker_collection.reload.products.to_a

    assert_queries 2 do
      pen_and_pencil, pen_and_marker = ProductCollectionCachedByCacheStore.where(id: [@pen_and_pencil_collection.id, @pen_and_marker_collection.id]).preload(:products).to_a
      assert_equal @pen_and_pencil_products.size, pen_and_pencil.products.size
      assert_equal @pen_and_marker_products.size, pen_and_marker.products.size

      @pen_and_pencil_products.each do |product|
        assert_includes pen_and_pencil.products, product
      end
      @pen_and_marker_products.each do |product|
        assert_includes pen_and_marker.products, product
      end
    end
  end

  def test_preload_auto_update_cache
    [@pen_and_pencil_collection, @pen_and_marker_collection].map(&:expire_cache)
    ProductCollectionCachedByCacheStore.where(id: [@pen_and_pencil_collection.id, @pen_and_marker_collection.id]).preload(:products).to_a
    assert @pen_and_pencil_collection.reload.cache_exists?
    assert @pen_and_marker_collection.reload.cache_exists?
  end

  def test_eager_load
    assert_raises do
      ProductCollectionCachedByCacheStore.where(id: [@pen_and_pencil_collection.id, @pen_and_marker_collection.id]).eager_load(:products).map{|x| x.products.to_a}
    end
  end

  def test_new_collection
    collection_by_id = ProductCollectionCachedByCacheStore.new(
      rule: {
        condition: {
          where: {
            id: @pen_catalog.products.map(&:id)
          }
        }
      }
    )

    assert_equal @pen_catalog.products.size, collection_by_id.products.size
    @pen_catalog.products.each do |product|
      assert_includes collection_by_id.products, product
    end
  end
end
