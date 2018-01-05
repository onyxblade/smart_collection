module SmartCollection
  class CacheManager

    def self.determine_class config
      case
      when config.dig(:cached_by, :table)
        SmartCollection::CacheManager::Table
      when config.dig(:cached_by, :cache_store)
      end
    end

    def initialize model:, config:
      @model = model
      @config = config
      @cache_config = config[:cached_by]
    end

    def update owner
      raise NotImplementedError
    end

    def read owner
      raise NotImplementedError
    end

    def expires_in
      @cache_config[:expires_in] || 1.hour
    end
  end
end
