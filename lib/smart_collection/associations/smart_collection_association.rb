module SmartCollection
  module Associations
    class SmartCollectionAssociation < ::ActiveRecord::Associations::HasManyAssociation

      def scope
        rules = self.owner.product_collection_rules.includes(:target)
        scope = rules.inject Product.unscoped do |scope, rule|
          scope.or(rule.target.association(rule.target_association).scope)
          scope
        end
      end

      def skip_statement_cache?
        true
      end

    end
  end
end