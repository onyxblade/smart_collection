module SmartCollection
  module Associations
    module Preloader
      class SmartCollection < ActiveRecord::Associations::Preloader::CollectionAssociation

      end
    end
  end

  module ActiveRecordPreloaderPatch
    def preloader_for(reflection, owners, rhs_klass)
      if reflection.options[:smart_collection] && !reflection.options[:smart_collection][:cache]
        raise RuntimeError, "Turn on cache to enable preloading."
        SmartCollection::Associations::Preloader::SmartCollection
      else
        super
      end
    end
  end

  ActiveRecord::Associations::Preloader.prepend ActiveRecordPreloaderPatch
end
