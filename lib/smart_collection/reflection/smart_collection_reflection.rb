module SmartCollection
  module Reflection
    class SmartCollectionReflection < ::ActiveRecord::Reflection::HasManyReflection
      def association_class
        Associations::SmartCollectionAssociation
      end

      def check_eager_loadable!
        raise RuntimeError, 'eager_load is not supported by now.'
      end
    end
  end
end
