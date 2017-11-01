module SmartCollection
  module Associations
    class SmartCollectionAssociation < ::ActiveRecord::Associations::HasManyAssociation

      class ScopeBuilder
        def initialize rule, klass
          @rule = rule
          @klass = klass
        end

        def build
          rule_to_scope @rule
        end

        def rule_to_scope rule
          case
          when ors = rule['or']
            ors.map{|x| rule_to_scope x}.inject(:or)
          when ands = rule['and']
            ands.map{|x| rule_to_scope x}.inject(:merge)
          when assoc = rule['association']
            klass = Object.const_get(assoc['class_name'])
            if COLLECTIONS[klass]
              klass.find(assoc['id']).association(assoc['source']).scope
            else
              klass.new(id: assoc['id']).association(assoc['source']).scope
            end
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

    end
  end
end