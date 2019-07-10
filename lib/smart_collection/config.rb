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

    def item_name
      items_name.to_s.singularize.to_sym
    end

    def item_class_name
      @raw_config[:class_name]
    end

    def item_class
      @item_class ||= item_class_name.constantize
    end

    def cache_config
      @raw_config[:cached_by]
    end

    def scopes_proc
      @raw_config[:scopes]
    end

    def inverse_association
      @raw_config[:inverse_association]
    end

    def cache_table_name
      :smart_collection_cached_items
    end
  end
end
