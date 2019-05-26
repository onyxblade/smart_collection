module SmartCollection
  class CacheManager
    class Table < CacheManager

      def initialize model:, config:
        super

        define_cache_association_for model
      end

      def define_cache_association_for model
        config = @config
        cached_item_model = nil
        model.class_eval do
          cached_item_model = Class.new ActiveRecord::Base do
            self.table_name = 'smart_collection_cached_items'
            belongs_to config.item_name, class_name: config.item_class_name, foreign_key: :item_id
          end
          const_set("CachedItem", cached_item_model)

          has_many :cached_items, class_name: cached_item_model.name, foreign_key: :collection_id
          has_many "cached_#{config.items_name}".to_sym, class_name: config.item_class_name, through: :cached_items, source: config.item_name
        end
        @cache_model = cached_item_model
      end

      def update owner
        @cache_model.where(collection_id: owner.id).delete_all
        @cache_model.connection.execute "INSERT INTO #{@cache_model.table_name} (collection_id, item_id) #{owner.smart_collection_mixin.uncached_scope(owner).select(owner.id, :id).to_sql}"
        owner.update_column(:cache_expires_at, Time.now + expires_in)
      end

      def read_scope owner
        cache_association = owner.association("cached_#{@config.items_name}")
        cache_association.scope
      end

      def cache_exists? owner
        owner.cache_expires_at && owner.cache_expires_at > Time.now
      end

    end
  end
end
