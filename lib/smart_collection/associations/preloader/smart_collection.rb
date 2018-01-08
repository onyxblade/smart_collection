module SmartCollection
  module Associations
    module Preloader
      class SmartCollectionCachedByTable < ActiveRecord::Associations::Preloader::HasManyThrough
        def through_reflection
          owners.first.class.reflect_on_association(:cached_items)
        end

        def source_reflection
          association_name = reflection.options[:smart_collection].items_name.to_s.singularize.to_sym
          through_reflection.klass.reflect_on_association(association_name)
        end

        def associated_records_by_owner preloader
          owners.reject(&:cache_exists?).each(&:update_cache)
          super
        end

        private

      end

      class SmartCollectionCachedByCacheStore < ActiveRecord::Associations::Preloader::CollectionAssociation
        def associated_records_by_owner preloader
          owners.reject(&:cache_exists?).each(&:update_cache)
          loaded = reflection.options[:smart_collection].cache_manager.read_multi(owners)
          records = reflection.options[:smart_collection].item_class.where(id: loaded.values.flatten.uniq).map{|x| [x.id, x]}.to_h
          loaded.map do |owner, ids|
            [owner, ids.map{|x| records[x]}]
          end
        end

        def preload(preloader)
          associated_records_by_owner(preloader).each do |owner, records|
            association = owner.association(reflection.name)
            association.loaded!
            association.target.concat(records)
          end
        end
      end
    end
  end

  module ActiveRecordPreloaderPatch
    def preloader_for(reflection, owners, rhs_klass)
      if reflection.options[:smart_collection]
        unless reflection.options[:smart_collection].cache_manager
          raise RuntimeError, "Turn on cache to enable preloading."
        end
        case reflection.options[:smart_collection].cache_manager
        when SmartCollection::CacheManager::CacheStore
          SmartCollection::Associations::Preloader::SmartCollectionCachedByCacheStore
        when SmartCollection::CacheManager::Table
          SmartCollection::Associations::Preloader::SmartCollectionCachedByTable
        end
      else
        super
      end
    end
  end

  ActiveRecord::Associations::Preloader.prepend ActiveRecordPreloaderPatch
end
