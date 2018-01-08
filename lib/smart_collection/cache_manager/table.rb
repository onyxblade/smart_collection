module SmartCollection
  class CacheManager
    class Table < CacheManager

      def initialize model:, config:
        super

        define_cache_association_for model
      end

      def define_cache_association_for model
        options = @config.raw_config
        cached_item_model = nil
        model.class_eval do
          cached_item_model = Class.new ActiveRecord::Base do
            self.table_name = 'smart_collection_cached_items'
            belongs_to options[:items].to_s.singularize.to_sym, class_name: options[:class_name], foreign_key: :item_id
          end
          const_set("CachedItem", cached_item_model)

          has_many :cached_items, class_name: cached_item_model.name, foreign_key: :collection_id
          has_many "cached_#{options[:items]}".to_sym, class_name: options[:class_name], through: :cached_items, source: options[:items].to_s.singularize.to_sym
        end
        @cache_model = cached_item_model
      end

      def update owner
        association = owner.association(@config.items_name)

        @cache_model.where(collection_id: owner.id).delete_all
        @cache_model.connection.execute "INSERT INTO #{@cache_model.table_name} (collection_id, item_id) #{association.uncached_scope.select(owner.id, :id).to_sql}"
        owner.update(cache_expires_at: Time.now + expires_in)
      end

      def read owner
        cache_association = owner.association("cached_#{@config.items_name}")
        cache_association.scope
      end

      def cache_exists? owner
        !(owner.cache_expires_at.nil? || owner.cache_expires_at < Time.now)
      end

    end
  end
end
