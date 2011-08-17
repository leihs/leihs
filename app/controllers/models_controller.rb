class ModelsController < FrontendController

  before_filter :pre_load

  def index( query = params[:query],
             sort = params[:sort] || 'name', # OPTIMIZE 0501
             sort_mode = params[:dir] || 'ASC' ) # OPTIMIZE 0501
             
    sort, sort_mode = params[:sort_and_sort_mode].split unless params[:sort_and_sort_mode].blank?
    
    sort_mode = sort_mode.downcase.to_sym # OPTIMIZE 0501
    
    #1402 TODO refactor to User#accessible_models(current_inventory_pools)
    model_ids = Model.all(:group => "models.id", #tmp#Rails3.1 is this select kept also for next Model query??# :select => "DISTINCT models.id",
                          :joins => [:items, :partitions],
                          :conditions => ["items.inventory_pool_id IN (:ip_ids)
                                             AND (partitions.group_id IN (:groups_ids)
                                             OR (partitions.group_id IS NULL AND partitions.inventory_pool_id IN (:ip_ids)))",
                                          {:ip_ids => current_inventory_pools.collect(&:id),
                                           :groups_ids => current_user.group_ids}
                                         ]).collect(&:id)
#tmp#
#    model_ids = Model.all(:select => "DISTINCT models.id",
#                          :joins => :items,
#                          :conditions => {:items => {:inventory_pool_id => current_inventory_pools.collect(&:id)}}).collect(&:id)
#    group_ids = current_user.group_ids_including_general
#    model_ids = model_ids.select {|m_id|  } or #model_ids.delete_if {|m|  }

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
  end  

#######################################################  
  
  def show
    @models = [@model]
    c = @models.size
    # OPTIMIZE used for InventoryPool#items_size
    InventoryPool.current_model, InventoryPool.current_user = [@model, current_user]
    
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
