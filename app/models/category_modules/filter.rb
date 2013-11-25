module CategoryModules
  module Filter

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods

      def filter (params, inventory_pool = nil)
        categories = Category.scoped
        categories = categories.search(params[:search_term]) if params[:search_term]
        categories = categories.order("name ASC")
        return categories
      end

    end

  end
end
