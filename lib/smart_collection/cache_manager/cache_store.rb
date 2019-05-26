module SmartCollection
  class CacheManager
    class CacheStore < CacheManager

      def initialize model:, config:
        super

        @cache_key_proc = @config.cache_config[:cache_key_proc] || -> (owner) { "_smart_collection_#{owner.class.name}_#{owner.id}" }
      end

      def cache_store
        @config.cache_config[:cache_store]
      end

      def cache_key owner
        @cache_key_proc.(owner)
      end

      def update owner
        cache_store.write(cache_key(owner), Marshal.dump(owner.smart_collection_mixin.uncached_scope(owner).pluck(:id)))
        owner.update(cache_expires_at: Time.now + expires_in)
      end

      def read_scope owner
        @config.item_class.where(id: Marshal.load(cache_store.read(cache_key owner)))
      end

      def read_multi owners
        cache_keys = owners.map{|owner| cache_key owner}
        loaded = cache_store.read_multi(*cache_keys)
        owners.map.with_index do |owner, index|
          [owner, Marshal.load(loaded[cache_keys[index]])]
        end.to_h
      end

      def cache_exists? owner
        owner.cache_expires_at && owner.cache_expires_at > Time.now && cache_store.exist?(cache_key owner)
      end

    end
  end
end
