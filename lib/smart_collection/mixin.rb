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

    def uncached_scope owner
      SmartCollection::ScopeBuilder.new(owner.rule, @config.item_class).build
    end

    def cached_scope owner
      @config.cache_manager.read_scope owner
    end

    def included base
      @config = config = SmartCollection::Config.new(@raw_config)

      reflection_options = {smart_collection: config}
      if config.item_class_name
        reflection_options[:class_name] = config.item_class_name
      end

      base.include(InstanceMethods)
      base.extend(ClassMethods)

      if cache_class = CacheManager.determine_class(@raw_config)
        config.cache_manager = cache_class.new(model: base, config: config)
      end

      mixin_options = {
        name: config.items_name,
        scope: -> owner {
          if cache_manager = config.cache_manager
            unless cache_manager.cache_exists? owner
              owner.update_cache
            end
            cached_scope(owner)
          else
            uncached_scope(owner)
          end
        },
        type: :collection
      }

      case
      when cache_class == SmartCollection::CacheManager::CacheStore
        mixin_options[:preloader] = -> owners {
          owners.reject(&:cache_exists?).each(&:update_cache)
          loaded = config.cache_manager.read_multi(owners)
          records = config.item_class.where(id: loaded.values.flatten.uniq).map{|x| [x.id, x]}.to_h
          loaded.map do |owner, ids|
            [owner, ids.map{|x| records[x]}]
          end.to_h
        }
      when cache_class == SmartCollection::CacheManager::Table
        cached_name = "cached_#{config.items_name}".to_sym
        mixin_options[:preloader] = -> owners {
          owners.reject(&:cache_exists?).each(&:update_cache)
          Associationist.preload(owners, cached_items: config.item_name)
          owners.map do |owner|
            [owner, owner.cached_items.map{|item| item.send(config.item_name)}]
          end.to_h
        }
      else
        mixin_options[:preloader] = -> _ {
          raise RuntimeError, "Turn on cache to enable preloading."
        }
      end
      base.include Associationist::Mixin.new(mixin_options)

      base.validates_with SmartCollection::Validator

    end
  end
end
