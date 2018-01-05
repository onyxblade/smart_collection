module SmartCollection
  module Reflection
    class SmartCollectionReflection < ::ActiveRecord::Reflection::HasManyReflection
      def association_class
        Associations::SmartCollectionAssociation
      end
    end
  end
end
