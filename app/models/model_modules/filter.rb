module ModelModules
  module Filter

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods

      def filter (params, subject = nil, category = nil, borrowable = false)
        models = if subject.is_a? User
          filter_for_user params, subject, category, borrowable 
        elsif subject.is_a? InventoryPool
          filter_for_inventory_pool params, subject, category
        else
          Model.scoped
        end
        models = models.where(id: params[:id]) if params[:id]
        models = models.where(id: params[:ids]) if params[:ids]
        models = models.joins(:items).where(:items => {:is_borrowable => true}) if borrowable or params[:borrowable]
        models = models.search(params[:search_term], [:name, :manufacturer]) unless params[:search_term].blank?
        models = models.order_by_attribute_and_direction params[:sort], params[:order]
        models = models.paginate(:page => params[:page]||1, :per_page => [(params[:per_page].try(&:to_i) || 20), 100].min) unless params[:paginate] == "false"
        return models
      end

      def filter_for_user (params, user, category, borrowable = false)
        models = if category then user.models.from_category_and_all_its_descendants(category.id).borrowable else user.models.borrowable end
        models = models.all_from_inventory_pools(user.inventory_pools.where(id: params[:inventory_pool_ids]).map(&:id)) unless params[:inventory_pool_ids].blank?
        return models
      end

      def filter_for_inventory_pool (params, inventory_pool, category)
        if params[:all]
          models = Model.scoped
        elsif params[:unused_models]
          models = Model.unused_for_inventory_pool inventory_pool
        else
          models = Model.joins(:items).where(":id IN (`items`.`owner_id`, `items`.`inventory_pool_id`)", :id => inventory_pool.id).uniq
          models = models.joins(:items).where(:items => {:retired => nil}) unless params[:include_retired_models]
          models = models.joins(:items).where(:items => {:parent_id => nil}) unless params[:include_package_models]
        end

        unless params[:unused_models]
          models = models.joins(:items).where(items: {id: params[:item_ids]}) if params[:item_ids]
          models = models.joins(:items).where(:items => {:inventory_pool_id => params[:responsible_id]}) if params[:responsible_id]
        end

        models = models.joins(:categories).where(:"model_groups.id" => [Category.find(params[:category_id])] + Category.find(params[:category_id]).descendants) unless params[:category_id].blank?
        models = models.joins(:model_links).where(:model_links => {:model_group_id => params[:template_id]}) if params[:template_id]
        return models
      end

    end

  end
end
