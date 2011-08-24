class ModelsController < FrontendController

  before_filter :pre_load

  def index( query = params[:query],
             sort = params[:sort] || 'name', # OPTIMIZE 0501
             sort_mode = params[:dir] || 'ASC' ) # OPTIMIZE 0501
    
    cookie_expire = 1.hour.from_now
    cookies[:active_ips] ||= {:value => current_user.active_inventory_pool_ids.to_json, :expires => cookie_expire }
    cookies[:start_date] ||= {:value => Date.today.to_json, :expires => cookie_expire }
    cookies[:end_date] ||= {:value => Date.tomorrow.to_json, :expires => cookie_expire }
    cookies[:show_available] ||= {:value => false.to_json, :expires => cookie_expire }
             
    sort, sort_mode = params[:sort_and_sort_mode].split unless params[:sort_and_sort_mode].blank?
    sort_mode = sort_mode.downcase.to_sym # OPTIMIZE 0501

    #1402 TODO refactor to User#accessible_models(current_inventory_pools)
    model_ids = Model.select("DISTINCT models.id"). #tmp# :group => "models.id", # is this select kept also for next Model query??
                      joins(:items, :partitions).
                      where(["items.inventory_pool_id IN (:ip_ids)
                                 AND (partitions.group_id IN (:groups_ids)
                                 OR (partitions.group_id IS NULL AND partitions.inventory_pool_id IN (:ip_ids)))",
                              {:ip_ids => current_inventory_pools.collect(&:id),
                               :groups_ids => current_user.group_ids}
                             ]).collect(&:id)

    with = {:sphinx_internal_id => model_ids }

    if params[:category_id]
      @category = Category.find(params[:category_id])
      with[:model_group_id] = @category.self_and_descendant_ids
    elsif params[:template_id]
      @template = Template.find(params[:template_id])
      with[:model_group_id] = @template.self_and_descendant_ids
    end

    @models = Model.search query, { :index => "frontend_model",
                                    :star => true,
                                    :per_page => 9999999,
                                    :with => with,
                                    :order => sort, :sort_mode => sort_mode }

    respond_to do |format|
      format.html
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
