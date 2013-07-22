module ModelModules
  module Filter

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods

      def filter (params, category, user, borrowable = false)
        models = if category then user.models.from_category_and_all_its_descendants(category.id).borrowable else user.models.borrowable end
        models = models.joins(:items).where(:items => {:parent_id => nil})
        models = models.joins(:items).where(:items => {:is_borrowable => true}) if borrowable
        models = models.all_from_inventory_pools(user.inventory_pools.where(id: params[:inventory_pool_ids]).map(&:id)) unless params[:inventory_pool_ids].blank?
        models = models.search(params[:search_term], [:name, :manufacturer]) unless params[:search_term].blank?
        models = models.order_by_attribute_and_direction params[:sort], params[:order]
        models = models.paginate(:page => params[:page]||1, :per_page => [(params[:per_page].try(&:to_i) || 20), 100].min)
        return models
      end

    end

  end
end