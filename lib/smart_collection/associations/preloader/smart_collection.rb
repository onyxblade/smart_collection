module SmartCollection
  module Associations
    module Preloader
      class SmartCollectionCachedByTable < ActiveRecord::Associations::Preloader::HasManyThrough
        def through_reflection
          reflection.active_record.reflect_on_association(:cached_items)
        end

        def source_reflection
          association_name = reflection.options[:smart_collection].item_name
          through_reflection.klass.reflect_on_association(association_name)
        end

        def associated_records_by_owner preloader
          owners.reject(&:cache_exists?).each(&:update_cache)
          super
        end
      end

      class SmartCollectionCachedByCacheStore < ActiveRecord::Associations::Preloader::CollectionAssociation
        def associated_records_by_owner preloader
          owners.reject(&:cache_exists?).each(&:update_cache)
          config = reflection.options[:smart_collection]
          loaded = config.cache_manager.read_multi(owners)
          records = config.item_class.where(id: loaded.values.flatten.uniq).map{|x| [x.id, x]}.to_h
          loaded.map do |owner, ids|
            [owner, ids.map{|x| records[x]}]
          end
        end
      end

    end
  end

  module ActiveRecordPreloaderPatch
    def preloader_for(reflection, owners, rhs_klass)
      config = reflection.options[:smart_collection]
      if config
        case config.cache_manager
        when SmartCollection::CacheManager::CacheStore
          SmartCollection::Associations::Preloader::SmartCollectionCachedByCacheStore
        when SmartCollection::CacheManager::Table
          SmartCollection::Associations::Preloader::SmartCollectionCachedByTable
        else
          raise RuntimeError, "Turn on cache to enable preloading."
        end
      else
        super
      end
    end
  end

  ActiveRecord::Associations::Preloader.prepend ActiveRecordPreloaderPatch
end
