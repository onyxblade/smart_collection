module SmartCollection
  class Mixin < Module
    def initialize config_proc
      @config_proc = config_proc
    end

    def included base
      name = :products
      reflection = Builder::SmartCollectionAssociation.build(base, name, nil, {})
      ::ActiveRecord::Reflection.add_reflection base, name, reflection
    end
  end
end