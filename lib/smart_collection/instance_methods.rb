module SmartCollection
  module InstanceMethods
    def update_cache
      smart_collection_mixin.config.cache_manager.update self
    end

    def expire_cache
      update_column(:cache_expires_at, Time.now - 1)
    end

    def cache_exists?
      smart_collection_mixin.config.cache_manager.cache_exists? self
    end

    def smart_collection_mixin
      self.class.smart_collection_mixin
    end
  end
end