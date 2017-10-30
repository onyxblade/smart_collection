module SmartCollection
  class Mixin < Module
    def initialize config_proc
      @config_proc = config_proc
    end

    def included base
      p base
    end
  end
end