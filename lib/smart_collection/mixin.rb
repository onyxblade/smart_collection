module SmartCollection
  class Mixin < Module
    def initialize items:, item_class: nil
      @smart_collection_config = {
        items: items,
        item_class: item_class
      }
    end

    def included base
      COLLECTIONS[base] = true
      name = @smart_collection_config[:items]
      options = {smart_collection: @smart_collection_config}
      options[:class_name] = @smart_collection_config[:item_class] if @smart_collection_config[:item_class]
      reflection = Builder::SmartCollectionAssociation.build(base, name, nil, options)
      ::ActiveRecord::Reflection.add_reflection base, name, reflection
    end
  end
end