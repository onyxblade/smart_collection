module SmartCollection
  module Associations
    module Preloader
      class SmartCollection < ActiveRecord::Associations::Preloader::HasManyThrough
        def through_reflection
          owners.first.class.reflect_on_association(:cached_items)
        end

        def source_reflection
          through_reflection.klass.reflect_on_association(:product)
        end

        def associated_records_by_owner preloader
          owners.reject(&:cache_exists?).each(&:update_cache)
          super
        end

        private

      end
    end
  end

  module ActiveRecordPreloaderPatch
    def preloader_for(reflection, owners, rhs_klass)
      if reflection.options[:smart_collection]
        unless reflection.options[:smart_collection].cache_manager
          raise RuntimeError, "Turn on cache to enable preloading."
        end
        SmartCollection::Associations::Preloader::SmartCollection
      else
        super
      end
    end
  end

  ActiveRecord::Associations::Preloader.prepend ActiveRecordPreloaderPatch
end
