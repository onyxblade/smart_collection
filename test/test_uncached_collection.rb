require_relative './test_helper'

class TestUncachedCollection < SmartCollection::Test
  def setup
    load_fixtures
    @pen_and_pencil_products = [@pen_catalog.products, @pencil_catalog.products].flatten
    @pen_and_marker_products = [@pen_catalog.products, @marker_catalog.products].flatten
  end

  def test_includes
    @pen_and_pencil_products.each do |product|
      assert_includes @pen_and_pencil_collection.products, product
      assert_includes @pen_and_pencil_collection.products.to_a, product
    end
  end

  def test_order
    ordered = @pen_and_pencil_collection.products.order(id: :desc).to_a
    assert_equal ordered.sort_by(&:id).reverse, ordered
  end

  def test_limit
    assert @pen_and_pencil_collection.products.size > 1
    assert_equal 1, @pen_and_pencil_collection.products.limit(1).size
  end

  def test_where
    whered = @pen_and_pencil_collection.products.where(id: @red_pen.id)
    assert_equal 1, whered.size
    assert_equal @red_pen, whered.first
  end

  def test_preload
    assert_raises do
      ProductCollection.preload(:products).find(@pen_and_pencil_collection.id)
    end
  end

  def test_eager_load
    assert_raises do
      ProductCollection.eager_load(:products).find(@pen_and_pencil_collection.id)
    end
  end

  def test_condition
    pen_and_pencil_cheaper_than_3_collection = ProductCollection.create(
      rule: {
        and: [
          {
            or: [
              {
                association: {
                  class_name: 'Catalog',
                  id: @pen_catalog.id,
                  source: 'products'
                }
              },
              {
                association: {
                  class_name: 'Catalog',
                  id: @pencil_catalog.id,
                  source: 'products'
                }
              }
            ]
          },
          {
            condition: {
              where: 'price < 3'
            }
          }
        ]
      }
    )

    expected_to_include = [@pen_catalog, @pencil_catalog].map(&:products).flatten.select{|x| x.price < 3}

    assert_equal expected_to_include.size, pen_and_pencil_cheaper_than_3_collection.products.size
    expected_to_include.each do |product|
      assert_includes pen_and_pencil_cheaper_than_3_collection.products, product
    end
  end

  def test_where_in_condition
    collection_by_id = ProductCollection.create(
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

  # TODO
  def test_new_collection
    collection_by_id = ProductCollection.new(
      rule: {
        condition: {
          where: {
            id: @pen_catalog.products.map(&:id)
          }
        }
      }
    )
    #assert_equal @pen_catalog.products.size, collection_by_id.products.size
    #@pen_catalog.products.each do |product|
    #  assert_includes collection_by_id.products, product
    #end
  end

  def test_collection_of_collection
    pen_and_pencil_cheaper_than_3_collection = ProductCollection.create(rule: {
      and: [
        {
          association: {
            class_name: 'ProductCollection',
            id: @pen_and_pencil_collection.id,
            source: 'products'
          }
        },
        {
          condition: {
            where: 'price < 3'
          }
        }
      ]
    })

    expected_to_include = [@pen_catalog, @pencil_catalog].map(&:products).flatten.select{|x| x.price < 3}

    assert_equal expected_to_include.size, pen_and_pencil_cheaper_than_3_collection.products.size
    expected_to_include.each do |product|
      assert_includes pen_and_pencil_cheaper_than_3_collection.products, product
    end
  end

  def test_scope_with_joins
    red_pen_and_pencil_collection = ProductCollection.create(rule: {
      and: [
        {
          association: {
            class_name: 'ProductCollection',
            id: @pen_and_pencil_collection.id,
            source: 'products'
          }
        },
        {
          condition: {
            joins: 'properties',
            where: {
              properties: {
                value: 'Red'
              }
            }
          }
        }
      ]
    })

    expected_to_include = [@pen_catalog, @pencil_catalog].map(&:products).flatten.select{|x| x.properties.find{|x| x.value == 'Red'}}
    assert_equal expected_to_include.size, red_pen_and_pencil_collection.products.size
    expected_to_include.each do |product|
      assert_includes red_pen_and_pencil_collection.products, product
    end
  end
end
