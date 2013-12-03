module InventoryModules
  module Filter

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods

      def filter (params, current_inventory_pool = nil)

        items = Item.filter params.clone.merge({paginate: "false", all: "true", search_term: nil}), current_inventory_pool

        if [:unborrowable, :retired, :category_id, :in_stock, :incomplete, :broken, :owned, :responsible_id, :unused_models].all? {|param| params[param].blank?}
          options = Option.filter params.clone.merge({paginate: "false", sort: "name", order: "ASC"}), current_inventory_pool
        end

        item_ids = items.pluck(:id)

        models = Model.filter params.clone.merge({paginate: "false", item_ids: item_ids, include_retired_models: params[:retired], search_targets: [:name, :items]}), current_inventory_pool

        inventory = (models + (options || [])).
                    sort{|a,b| a.name.strip <=> b.name.strip}

        inventory = inventory.paginate(:page => params[:page]||1, :per_page => [(params[:per_page].try(&:to_i) || 20), 100].min) unless params[:paginate] == "false"

        return inventory
      end

    end

  end
end
