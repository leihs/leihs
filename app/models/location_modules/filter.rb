module LocationModules
  module Filter

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods

      def filter (params)
        locations = Location.where(id: params[:ids]) if params[:ids]
        return locations
      end

    end

  end
end
