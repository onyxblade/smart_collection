module SmartCollection
  class CacheManager
    class CacheStore < CacheManager

      def cache_store
        @config.cache_config[:cache_store]
      end

      def cache_key owner
        "_smart_collection_#{owner.class.name}_#{owner.id}"
      end

      def update owner
        association = owner.association(@config.items_name)

        cache_store.write(cache_key(owner), Marshal.dump(association.uncached_scope.pluck(:id)))
        owner.update(cache_expires_at: Time.now + expires_in)
      end

      def read owner
        @config.item_class.where(id: Marshal.load(cache_store.read(cache_key owner)))
      end

      def cache_exists? owner
        owner.cache_expires_at.nil? || owner.cache_expires_at < Time.now || cache_store.read(cache_key owner)
      end

    end
  end
end
