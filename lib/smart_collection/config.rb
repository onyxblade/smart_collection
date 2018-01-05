module SmartCollection
  class Config
    attr_accessor :cache_manager

    def initialize raw_config
      @raw_config = raw_config
    end

    def items_name
      @raw_config[:items]
    end

    def item_class_name
      @raw_config[:item_class]
    end
  end
end
