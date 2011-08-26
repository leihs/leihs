class ModelsController < FrontendController
  
  before_filter :pre_load

  def index
    cookie_expire = 1.hour.from_now
    cookies[:active_ips] ||= {:value => current_user.active_inventory_pool_ids.to_json, :expires => cookie_expire }
    cookies[:start_date] ||= {:value => Date.today.to_json, :expires => cookie_expire }
    cookies[:end_date] ||= {:value => Date.tomorrow.to_json, :expires => cookie_expire }
    cookies[:show_available] ||= {:value => false.to_json, :expires => cookie_expire }
             
    model_group = if params[:category_id]
      @category = Category.includes(:children).find(params[:category_id])
      @category_children = @category.children
      @category
    elsif params[:template_id]
      @template = Template.includes(:children).find(params[:template_id])
      @template_children = @template.children
      @template
    else
      # models index is always nested either to a category or to a template
    end

    #1402 TODO refactor to User#accessible_models
    @models = model_group.all_models.
                      joins(:items, :partitions).
                      includes(:inventory_pools, :properties, :images).
                      where(["items.inventory_pool_id IN (:ip_ids)
                              AND (partitions.group_id IN (:groups_ids)
                                   OR (partitions.group_id IS NULL AND partitions.inventory_pool_id IN (:ip_ids)))",
                              {:ip_ids => current_user.active_inventory_pool_ids,
                               :groups_ids => current_user.group_ids} ])

    respond_to do |format|
      format.html {}
      format.js { render :json => @models.as_json(:current_user => current_user) }
    end
  end  

#######################################################  
  
  def show
    respond_to do |format|
      format.html
    end
  end

#################################################################

  def chart
    render :layout => false
  end

#################################################################

  def book
  end

#################################################################

  private
  
  def pre_load
    params[:model_id] ||= params[:id] if params[:id]
    @model = current_user.models.find(params[:model_id]) if params[:model_id]
    @inventory_pool = current_user.inventory_pools.find(params[:inventory_pool_id]) if params[:inventory_pool_id]
  end


end
