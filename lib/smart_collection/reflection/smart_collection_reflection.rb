module SmartCollection
  module Reflection
    class SmartCollectionReflection < ::ActiveRecord::Reflection::HasManyReflection
      def association_class
        Associations::SmartCollectionAssociation
      end

      def check_eager_loadable!
        unless options[:smart_collection].cache_manager.instance_of? SmartCollection::CacheManager::Table
          raise RuntimeError, 'eager_load is only supported when using table for cache.'
        end
      end

      def chain
        items_name = options[:smart_collection].items_name
        active_record.reflect_on_association("cached_#{items_name}".to_sym).chain
      end
    end
  end
end
