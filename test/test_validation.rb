require_relative './test_helper'

class TestValidation < SmartCollection::Test
  def test_validation
    collection = ProductCollection.new(rule: {
      condition: {
        where: 123
      }
    })
    refute collection.valid?
  end

end
