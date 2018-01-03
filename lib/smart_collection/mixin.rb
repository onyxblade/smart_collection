module SmartCollection
  class Mixin < Module
    module InstanceMethods
      def update_cache
        cache_by = smart_collection_mixin.config[:cache_by]
        association = self.association(smart_collection_mixin.config[:items])
        case
        when cache_by[:table]
          cache_model = cache_by[:cache_model]
          cache_model.where(collection_id: self.id).delete_all
          cache_model.connection.execute "INSERT INTO #{cache_model.table_name} (collection_id, item_id) #{association.scope.select(self.id, :id).to_sql}"
        else
          raise "cannot update cache due to no cache setted."
        end

      end

      def smart_collection_mixin
        @__smart_collection_mixin ||= self.class.ancestors.find do |x|
          x.instance_of? Mixin
        end
      end
    end

    def initialize items:, item_class: nil, cache_by: nil
      @smart_collection_config = {
        items: items,
        item_class: item_class,
        cache_by: cache_by
      }
    end

    def config
      @smart_collection_config
    end

    def included base
      COLLECTIONS[base] = true
      name = @smart_collection_config[:items]
      options = {smart_collection: @smart_collection_config}
      options[:class_name] = @smart_collection_config[:item_class] if @smart_collection_config[:item_class]
      reflection = Builder::SmartCollectionAssociation.build(base, name, nil, options)
      ::ActiveRecord::Reflection.add_reflection base, name, reflection
      base.include(InstanceMethods)

      if @smart_collection_config.dig(:cache_by, :table)
        base.class_eval do
          cached_item_model = Class.new ActiveRecord::Base do
            self.table_name = 'smart_collection_cached_items'
            belongs_to name.to_s.singularize.to_sym, class_name: options[:class_name], foreign_key: :item_id
          end
          const_set("CachedItem", cached_item_model)
          options[:smart_collection][:cache_by][:cache_model] = cached_item_model
          has_many :cached_items, class_name: cached_item_model.name, foreign_key: :collection_id
          has_many "cached_#{name}".to_sym, class_name: options[:class_name], through: :cached_items, source: name.to_s.singularize.to_sym
        end
      end

    end
  end
end
