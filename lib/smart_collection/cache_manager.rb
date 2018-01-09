module SmartCollection
  class CacheManager

    def self.determine_class config
      case
      when config.dig(:cached_by, :table)
        SmartCollection::CacheManager::Table
      when config.dig(:cached_by, :cache_store)
        SmartCollection::CacheManager::CacheStore
      end
    end

    def initialize model:, config:
      @model = model
      @config = config
    end

    def update owner
      raise NotImplementedError
    end

    def read_scope owner
      raise NotImplementedError
    end

    def cache_exists? owner
      raise NotImplementedError
    end

    def expires_in
      @config.cache_config[:expires_in] || 1.hour
    end
  end
end
