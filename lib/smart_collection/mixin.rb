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
        self.class.smart_collection_mixin
      end
    end

    module ClassMethods
      def smart_collection_mixin
        @__smart_collection_mixin ||= ancestors.find do |x|
          x.instance_of? Mixin
        end
      end
    end

    attr_reader :config

    def initialize raw_config
      @raw_config = raw_config
    end

    def included base
      @config = config = SmartCollection::Config.new(@raw_config)

      reflection_options = {smart_collection: config}
      if config.item_class_name
        reflection_options[:class_name] = config.item_class_name
      end

      reflection = Builder::SmartCollectionAssociation.build(base, config.items_name, nil, reflection_options)
      ::ActiveRecord::Reflection.add_reflection base, config.items_name, reflection

      base.include(InstanceMethods)
      base.extend(ClassMethods)

      if cache_class = CacheManager.determine_class(@raw_config)
        config.cache_manager = cache_class.new(model: base, config: config)
      end

    end
  end
end
