module SmartCollection
  class Config
    attr_accessor :cache_manager
    attr_reader :raw_config

    def initialize raw_config
      @raw_config = raw_config
      check_config
    end

    def items_name
      @raw_config[:item_association]
    end

    def item_name
      items_name.to_s.singularize.to_sym
    end

    def item_class_name
      @raw_config[:item_class_name]
    end

    def item_class
      @item_class ||= item_class_name.constantize
    end

    def cache_config
      @raw_config[:cached_by]
    end

    def scopes_proc
      case @raw_config[:scopes]
      when Proc
        @raw_config[:scopes]
      when Symbol
        -> (owner) { owner.send(@raw_config[:scopes]) }
      else
        raise "scopes option only accepts a Proc / Symbol"
      end
    end

    def inverse_association
      @raw_config[:inverse_association]
    end

    def cache_table_name
      if @raw_config[:cache_table] == :default
        :smart_collection_cached_items
      else
        @raw_config[:cache_table]
      end
    end

    def cache_expires_in_proc
      case @raw_config[:cache_expires_in]
      when Proc
        @raw_config[:cache_expires_in]
      when ActiveSupport::Duration
        -> (owner) { @raw_config[:cache_expires_in] }
      when Symbol
        -> (owner) { owner.send(@raw_config[:cache_expires_in]) }
      else
        raise "cache_expires_in option only accepts a Proc / ActiveSupport::Duration / Symbol"
      end
    end

    def check_config
      raise "items option must be provided" if items_name.nil?
      raise "item_class option must be provided" if item_class_name.nil?
      raise "scopes option must be provided" if @raw_config[:scopes].nil?
      raise "cache_table option must be provided" if @raw_config[:cache_table].nil?
      raise "cache_expires_in option must be provided" if @raw_config[:cache_expires_in].nil?
    end
  end
end
