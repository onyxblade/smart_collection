module SmartCollection
  class Validator < ActiveModel::Validator
    def validate record
      # try to build scope
      record.association(record.smart_collection_mixin.config.items_name).scope
    rescue Exception => e
      record.errors.add(:failed_to_build_scope, e)
    end
  end
end
