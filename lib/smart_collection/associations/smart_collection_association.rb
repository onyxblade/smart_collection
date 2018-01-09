module SmartCollection
  module Associations
    class SmartCollectionAssociation < ::ActiveRecord::Associations::HasManyAssociation

      class ScopeBuilder
        def initialize rule, klass
          @rule = rule
          @klass = klass
          @klass_hash = {}
        end

        def build
          rule_to_bulk_queries @rule
          bulk_load
          rule_to_scope @rule
        end

        def bulk_load
          @klass_hash = @klass_hash.map do |klass_name, ids|
            [klass_name, Object.const_get(klass_name).where(id: ids).map{|x| [x.id, x]}.to_h]
          end.to_h
        end

        def rule_to_bulk_queries rule
          case
          when arr = (rule['or'] || rule['and'])
            arr.each{|x| rule_to_bulk_queries x}
          when assoc = rule['association']
            ids = @klass_hash[assoc['class_name']] ||= []
            ids << assoc['id']
          end
        end

        def rule_to_scope rule
          case
          when ors = rule['or']
            ors.map{|x| rule_to_scope x}.inject(:or)
          when ands = rule['and']
            ands.map{|x| rule_to_scope x}.inject(:merge)
          when assoc = rule['association']
            @klass_hash[assoc['class_name']][assoc['id']].association(assoc['source']).scope
          when cond = rule['condition']
            scope = @klass
            scope = scope.joins(cond['joins'].to_sym) if cond['joins']
            scope.where(cond['where'])
          end
        end
      end

      def association_scope
        if cache_manager = reflection.options[:smart_collection].cache_manager
          unless cache_manager.cache_exists? owner
            owner.update_cache
          end
          cached_scope
        else
          uncached_scope
        end
      end

      def skip_statement_cache?
        true
      end

      def uncached_scope
        ScopeBuilder.new(owner.rule, reflection.klass).build
      end

      def cached_scope
        reflection.options[:smart_collection].cache_manager.read_scope owner
      end

    end
  end
end
