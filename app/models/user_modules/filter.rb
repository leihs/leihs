module UserModules
  module Filter

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods

      def filter (params, current_inventory_pool = nil)
        # NOTE if params[:role] == "all" is provided, then we have to skip the deleted access_rights, so we fetch directly from User
        # NOTE the case of fetching users with specific ids from a specific inventory_pool is still missing, might be necessary in future
        if current_inventory_pool and params[:all].blank?
          users = params[:suspended] == "true" ? current_inventory_pool.suspended_users : current_inventory_pool.users
          users = users.send params[:role] unless params[:role].blank?
        else
          users = User.scoped
        end

        users = users.admins if params[:role] == "admins"
        users = users.where(id: params[:ids]) if params[:ids]
        users = users.search(params[:search_term]) if params[:search_term]
        users = users.order(User.arel_table[:firstname].asc)
        users = users.paginate(:page => params[:page] || 1, :per_page => [(params[:per_page].try(&:to_i) || 20), 100].min) unless params[:paginate] == "false"
        return users
      end

    end

  end
end
