module SmartCollection
  class Config
    attr_accessor :cache_manager
    attr_reader :raw_config

    def initialize raw_config
      @raw_config = raw_config
    end

    def items_name
      @raw_config[:items]
    end

    def item_class_name
      @raw_config[:item_class]
    end

    def item_class
      item_class_name.constantize
    end

    def cache_config
      @raw_config[:cached_by]
    end
  end
end
