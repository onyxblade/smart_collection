module SmartCollection
  class Mixin < Module
    module InstanceMethods
      def update_cache
        smart_collection_mixin.config.cache_manager.update self
      end

      def expire_cache
        update_column(:cache_expires_at, nil)
      end

      def cache_exists?
        smart_collection_mixin.config.cache_manager.cache_exists? self
      end

      def smart_collection_mixin
        @__smart_collection_mixin ||= self.class.ancestors.find do |x|
          x.instance_of? Mixin
        end
      end
    end

    attr_reader :config

    def initialize items:, item_class: nil, cached_by: nil
      @raw_config = {
        items: items,
        item_class: item_class,
        cached_by: cached_by
      }
    end

    def included base
      COLLECTIONS[base] = true
      @config = config = SmartCollection::Config.new(@raw_config)
      name = config.items_name

      options = {smart_collection: config}
      options[:class_name] = config.item_class_name if config.item_class_name
      reflection = Builder::SmartCollectionAssociation.build(base, name, nil, options)
      ::ActiveRecord::Reflection.add_reflection base, name, reflection
      base.include(InstanceMethods)

      if cache_class = CacheManager.determine_class(@raw_config)
        config.cache_manager = cache_class.new(model: base, config: config)
      end

    end
  end
end
