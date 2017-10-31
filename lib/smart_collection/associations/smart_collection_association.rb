module SmartCollection
  module Associations
    class SmartCollectionAssociation < ::ActiveRecord::Associations::HasManyAssociation

      def association_scope
        rule_to_scope owner.rule
      end

      def rule_to_scope rule
        case
        when rule['or']
          rule['or'].map{|x| rule_to_scope x}.inject(:or)
        when rule['type']
          case rule['type']
          when 'include'
            Object.const_get(rule['target_type']).find(rule['target_id']).association(rule['target_association']).scope
          end
        end
      end

      def skip_statement_cache?
        true
      end

    end
  end
end