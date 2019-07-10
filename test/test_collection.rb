require_relative './test_helper'

class TestCollection < SmartCollection::Test
  def setup
    @group_a = 3.times.map{ Product.create }
    @group_b = 3.times.map{ Product.create }
    @group_c = 3.times.map{ Product.create }

    @scope_of_group_a = Product.where(id: @group_a.map(&:id))
    @scope_of_group_b = Product.where(id: @group_b.map(&:id))
    @scope_of_group_c = Product.where(id: @group_c.map(&:id))
  end

  def test_ensure_association_loaded
    collection = collection_with_scopes([])
    refute collection.products.loaded?

    ensure_association_loaded collection
    assert collection.products.loaded?
  end

  def test_reload_and_reset_scopes
    collection = collection_with_scopes([])
    ensure_association_loaded collection

    assert collection.products.loaded?

    reload_and_reset_scopes(collection, [])
    refute collection.products.loaded?
  end

  def test_collection_with_scopes
    collection = collection_with_scopes([@scope_of_group_a])
    refute collection.new_record?
    refute collection.changed?
  end

  def test_load_by_scopes
    scopes = [@scope_of_group_a, @scope_of_group_b, @scope_of_group_c]
    collection = collection_with_scopes(scopes)
    assert_equal scopes.inject(:+), collection.products
  end

  def test_update_cache
    collection = Collection.create
    collection.scopes = [@scope_of_group_a]
    assert_equal @scope_of_group_a, collection.products

    reload_and_reset_scopes(collection, [@scope_of_group_b])
    refute_equal @scope_of_group_b, collection.products

    reload_and_reset_scopes(collection, [@scope_of_group_b])
    collection.update_cache
    assert_equal @scope_of_group_b, collection.products
  end

  def test_expire_cache
    collection = collection_with_scopes([])
    collection.update_cache
    assert collection.cache_exists?
    collection.expire_cache
    refute collection.cache_exists?
  end

  def test_expired_scope
    collection = collection_with_scopes([])
    collection.expire_cache

    collection.class.smart_collection_mixin.expired_scope(collection.class).include?(collection)
  end

  def test_auto_update_cache
    collection = collection_with_scopes([@scope_of_group_a])
    ensure_association_loaded collection

    collection.expire_cache
    reload_and_reset_scopes(collection, [@scope_of_group_b])
    ensure_association_loaded collection

    assert collection.cache_expires_at > Time.now
    assert_equal @scope_of_group_b, collection.products
  end

  def test_preload
    collection_a = collection_with_scopes([@scope_of_group_a])
    collection_b = collection_with_scopes([@scope_of_group_b])

    ensure_association_loaded collection_a
    ensure_association_loaded collection_b

    products_of_group_a = @scope_of_group_a.to_a
    products_of_group_b = @scope_of_group_b.to_a

    assert_queries 3 do
      collection_a, collection_b = Collection.where(id: [collection_a, collection_b]).preload(:products).to_a

      assert_equal products_of_group_a, collection_a.products
      assert_equal products_of_group_b, collection_b.products
    end
  end

  def test_preload_auto_update_cache
    collection_a = collection_with_scopes([@scope_of_group_a])
    collection_b = collection_with_scopes([@scope_of_group_b])
    [collection_a, collection_b].map(&:expire_cache)

    Collection.where(id: [collection_a, collection_b]).preload(:products).to_a
    assert collection_a.reload.cache_exists?
    assert collection_b.reload.cache_exists?
  end

end
