require_relative './test_helper'

class TestInverseAssociation < SmartCollection::Test
  def setup
    @group_a = 3.times.map{ Product.create }
    @group_b = 3.times.map{ Product.create }
    @group_c = 3.times.map{ Product.create }

    @scope_of_group_a = Product.where(id: @group_a.map(&:id))
    @scope_of_group_b = Product.where(id: @group_b.map(&:id))
    @scope_of_group_c = Product.where(id: @group_c.map(&:id))
  end

  def test_inverse_association
    collections = 3.times.map{ Collection.create(scopes: [@scope_of_group_a]) }
    collections.each{|collection| ensure_association_loaded collection }

    product = @group_a.first
    assert_equal product.reload.collections, collections
  end

  def test_auto_update_cache
    collections = 3.times.map{ Collection.create(scopes: [@scope_of_group_a]) }
    collections.each{|collection| ensure_association_loaded collection }

    collections.each(&:expire_cache)
    collections.each{|collection| refute collection.cache_exists? }

    product = @group_a.first
    assert_equal product.reload.collections, collections
    collections.each(&:reload)
    collections.each{|collection| assert collection.reload.cache_exists? }
  end

end
