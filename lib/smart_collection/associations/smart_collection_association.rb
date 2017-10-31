module SmartCollection
  module Associations
    class SmartCollectionAssociation < ::ActiveRecord::Associations::HasManyAssociation

      def association_scope
        rules_association = reflection.options[:smart_collection][:rules]
        rules = self.owner.public_send(rules_association).includes(:target)
        scope = rules.map{|rule| rule.target.association(rule.target_association).scope}.inject(:or)
      end

      def skip_statement_cache?
        true
      end

    end
  end
end