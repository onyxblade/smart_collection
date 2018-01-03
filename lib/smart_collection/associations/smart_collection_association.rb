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
            case cond['operator']
            when 'lt'
              @klass.where("#{cond['field']} < #{cond['value']}")
            when 'lte'
              @klass.where("#{cond['field']} <= #{cond['value']}")
            when 'gt'
              @klass.where("#{cond['field']} > #{cond['value']}")
            when 'gte'
              @klass.where("#{cond['field']} >= #{cond['value']}")
            end
          end
        end
      end

      def association_scope
        ScopeBuilder.new(owner.rule, reflection.klass).build
      end

      def skip_statement_cache?
        true
      end

      def cached_scope
        cache_by = reflection.options[:smart_collection][:cache_by]
        case
        when cache_by[:table]
          owner
        end
      end

    end
  end
end
