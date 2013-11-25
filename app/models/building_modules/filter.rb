module BuildingModules
  module Filter

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods

      def filter (params)
        buildings = Building.where(id: params[:ids]) if params[:ids]
        return buildings
      end

    end

  end
end
